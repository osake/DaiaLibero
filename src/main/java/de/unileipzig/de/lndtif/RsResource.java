/*
 * Copyright (C) 2014 Project finc, finc@ub.uni-leipzig.de
 * Leipzig University Library, Project finc
 * http://www.ub.uni-leipzig.de
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * http://opensource.org/licenses/gpl-3.0.html GNU General Public License
 * http://finc.info Project finc
 */

package de.unileipzig.de.lndtif;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import de.gbv.ws.daia.Availability;
import de.gbv.ws.daia.Daia;
import de.gbv.ws.daia.DaiaAvailability;
import de.gbv.ws.daia.Document;
import de.gbv.ws.daia.Item;
import de.gbv.ws.daia.Label;
import de.gbv.ws.daia.Message;
import de.gbv.ws.daia.SimpleElement;
import de.unileipzig.ub.linkeddata.Caller;
import de.unileipzig.ub.linkeddata.Helper;
import de.unileipzig.ub.linkeddata.http.client.ApHttpClient;
import de.unileipzig.ub.linkeddata.solr.Doc;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.math.BigInteger;
import java.net.URLEncoder;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
import java.util.Date;
import java.util.Enumeration;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import javax.servlet.ServletContext;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;
import javax.xml.bind.JAXBContext;
import javax.xml.bind.Marshaller;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.unileipzig.ub.libero.cacheupdater.json.TitleInformation;
import org.unileipzig.ub.libero.cacheupdater.json.TitleInformationObject;
import org.unileipzig.ub.libero.cacheupdater.json.TitleItem;

/**
 * <p>REST Web Service.</p>
 * 
 * <p>Siehe <a href="https://intern.finc.info/issues/2644">Ticket #2644</a>.</p>
 * 
 * @author Polichronis Tsolakidis <tsolakidis@ub.uni-leipzig.de>
 */
@Path("")
public class RsResource {

    // @Context private        UriInfo context;
    @Context private ServletContext sc;

    private static final         Gson gson = new GsonBuilder().setPrettyPrinting().create();

    // XSLT cache
    private static               Long time = -1L;
    private static             String xslt;
    
    private static final Logger logger = Logger.getLogger( RsResource.class );
    
    private static final Map<String,String> webOpacId = new HashMap();
    
    private static final String SCHEMA_LOCATION = "http://ws.gbv.de/daia/ http://ws.gbv.de/daia/daia.xsd";
    
    /**
     * Creates a new instance of RsResource
     */
    public RsResource() {}

    /**
     * Info text.
     * 
     * @return Info screen
     * @throws Exception 
     */
    @GET
    @Path("/")
    @Produces( value = "text/plain" )
    public String getInfo() throws Exception {
        File file = new File(sc.getResource("/WEB-INF/resources/info.txt").toURI());
        if( (file.exists() && file.canRead()) ) {
            try (
                BufferedReader br = new BufferedReader(
                    new InputStreamReader(
                        new FileInputStream(file)));
            ) {
                StringBuilder sb = new StringBuilder();
                String line;
                while ( (line = br.readLine()) != null) sb.append(line).append("\n");
                return sb.toString();
            }
        }
        return "Info not found.";
    }
    
    /**
     * Retrieves RDF+XML.
     * 
     * @param isil Library ISIL number or '*'.
     * @param ns namespace.
     * @param id ID,PPN,.. according to namespace.
     * @return RDF+XML data.
     * @throws java.lang.Exception
     */
    @GET
    @Path("/title/{isil}/{ns: (finc|zdb|swb)}/{id}")
    public Response getTitleData(@PathParam("isil") String isil, @PathParam("ns") String ns, @PathParam("id") String id) throws Exception {
        String solrUrl = sc.getInitParameter( "SOLR_SELECT_BASE_URL" );
        if( solrUrl == null || solrUrl.isEmpty()) {
            throw new WebApplicationException(
                daiaErrorMessage( Response.Status.SERVICE_UNAVAILABLE, "'SOLR_SELECT_BASE_URL' is not defined. Check your config!"));
        }
        String sb = isil;
        if( !sb.equals("*") ) {
            Set<String> isilList = getIsilList(isil);
            if( isilList.isEmpty() ) isilList.add(sb);
            sb = buildIsilSubQuery(isilList);
            if( sb == null || sb.isEmpty() ) {
                throw new WebApplicationException(
                    daiaErrorMessage( Response.Status.BAD_REQUEST, "Unknown ISIL. Check your config!"));
            }
        } else {
            sb = ""; // search in all sigel's
        }
        
        Map<String, String> solrNsMapping = getSolrNsMapping();
        if( solrNsMapping == null || solrNsMapping.isEmpty() || !solrNsMapping.containsKey(ns)) {
            throw new WebApplicationException(
                daiaErrorMessage( Response.Status.BAD_REQUEST, "Namespace is not defined. Check your config!"));
        }
        
        String idStr = solrNsMapping.get(ns);
        
        String urlStr = String.format(
            "%s?q=%s:%s%s&wt=json&fl=id,record_id",
            solrUrl,
            idStr,
            id,
            sb.isEmpty() ? sb : String.format( "%%20AND%%20%s", sb)
        );
        Doc doc = ApHttpClient.solrCall( urlStr );
        if( doc == null) {
            throw new WebApplicationException(
                daiaErrorMessage( Response.Status.NOT_FOUND, "SOLR has produced an empty response."));
        }
        String fincId = doc.getId();
        byte[] marcBlob = getFullRecord(fincId);
        if( marcBlob == null || marcBlob.length == 0) {
            throw new WebApplicationException(
                daiaErrorMessage( Response.Status.NOT_FOUND, fincId + " => Marc blob not found."));
        }
        String rdf = Caller.toRDF( marcBlob, getStylesheet( sc.getInitParameter( "XSLT" ) ));
        return Response.ok( rdf, "application/rdf+xml").build();
    }
    
    /**
     * Retrieves DAIA.
     * 
     * @param isil Library ISIL number.
     * @param ns namespace.
     * @param id ID,PPN,.. according to namespace.
     * @return RDF+XML data.
     * @throws java.lang.Exception
     */
    @GET
    @Path("/item/{isil}/{ns: (finc|callnumber|barcode)}/{id}")
    public Response getItemData(@PathParam("isil") String isil, @PathParam("ns") String ns, @PathParam("id") String id) throws Exception {

        Set<String> isilList = getIsilList(isil);
        if( isilList.isEmpty() ) isilList.add( isil );
        String isilQueryList = buildIsilSubQuery(isilList);

        String identifier = "";
        Map<String, String> nsm = getSolrNsMapping();
        if( nsm != null && nsm.containsKey(ns) ) {
            identifier = nsm.get(ns);
        } else {
            logger.warn( String.format( "Namespace '%s' is not defined.", ns == null ? "" : ns));
        }

        List<String> idList = new ArrayList<>();
        for( String i : isilList) {
            if( identifier.equals("id")) { // fincid
                idList.add( URLEncoder.encode( identifier + ":" + id, "UTF-8") );
            } else {
                idList.add( URLEncoder.encode( identifier + ":\"(" + i + ")" + id + "\"", "UTF-8") );
            }
        }
        String join1 = "(" + Helper.join(idList, "%20OR%20") + ")";
        
        String solrUrl = sc.getInitParameter( "SOLR_SELECT_BASE_URL" );
        if( solrUrl == null || solrUrl.isEmpty()) {
            String errStr = "'SOLR_SELECT_BASE_URL' not defined. Check your config!";
            logger.fatal(errStr);
            throw new WebApplicationException(
                daiaErrorMessage( Response.Status.SERVICE_UNAVAILABLE, errStr));
        }
        String urlStr = String.format(
            "%s?q=%s%%20AND%%20%s&wt=json&fl=id,record_id,signatur,barcode,itemdata,source_id",
            solrUrl,
            isilQueryList,
            join1
        );
        Doc doc = ApHttpClient.solrCall( urlStr );
        if( doc == null ) {
            String errStr = "SOLR has produced an empty response.";
            logger.fatal(errStr);
            throw new WebApplicationException(
                daiaErrorMessage( Response.Status.NOT_FOUND, errStr));
        }

        String ldrvUrl = sc.getInitParameter( "LIBERO_DRV_BASE_URI" );
        if( ldrvUrl == null || ldrvUrl.isEmpty()) {
            String errStr = "'LIBERO_DRV_BASE_URI' not defined. Check your config!";
            logger.fatal(errStr);
            throw new WebApplicationException(
                daiaErrorMessage( Response.Status.SERVICE_UNAVAILABLE, errStr));
        }

        String dbName   = getOpacId(isil);
        String recordId = doc.getRecordId();

        try {
            Callable<DataResult> callable = new DataResultCallable( ldrvUrl, dbName, recordId);
            ExecutorService executor = Executors.newCachedThreadPool();
            Future<DataResult> result = executor.submit(callable);
            DataResult dataResult = result.get();
            executor.shutdown();

            Document daiaDoc = new Document();
            daiaDoc.setId("finc:" + doc.getId());
            daiaDoc.setHref( sc.getInitParameter("CATALOGUE_URL") + "Record/" + doc.getId());
             
            List<Object> objList = daiaDoc.getMessageOrItem();
            TitleInformationObject to = dataResult.getTo();
            Map availability = dataResult.getAvailability();
            Map<String, Map> availabilityList = getAvailabilityList(availability);
            if( to != null ) {
                Map<String, TitleInformation> ti = to.getGetTitleInformation();
                if( ti != null ) {
                    Set<Map.Entry<String, TitleInformation>> entrySet = ti.entrySet();
                    for( Map.Entry<String, TitleInformation> e : entrySet) {
                        TitleInformation value = e.getValue();
                        if( value != null && value.getTitle_items() != null ) {
                            for( TitleItem i : value.getTitle_items()) {

                                String barcode = i.getBarcode();

                                Map avMap = availabilityList.get(barcode);
                                if( avMap == null || avMap.isEmpty() ) continue;
                                // Bsp.: "rid": "303873167"
                                String location = (String) avMap.get("location");
                                String status   = (String) avMap.get("status");
                                String branch   = (String) avMap.get("branch");
                                if( (branch == null || branch.trim().isEmpty()) && location != null && !location.trim().isEmpty()) branch = location;

                                String duedate = getDelay( (String) avMap.get("duedate") );

                                Item item = new Item();

                                item.setId( "finc:" + doc.getId() + ":(" + isil + ")" + barcode );
                                String call_number = i.getCall_number();
                                if( call_number != null && !call_number.isEmpty()) {
                                    Label label = new Label();
                                    label.setContent( i.getCall_number() );
                                    item.setLabel( label );
                                }
                                if( branch != null && !branch.trim().isEmpty()) {
                                    SimpleElement storage = new SimpleElement();
                                    storage.setContent( branch );
                                    item.setStorage( storage );
                                }
                                item.setHref(sc.getInitParameter( "CATALOGUE_URL" ) + "Record/" + doc.getId() );

                                // show status string
                                SimpleElement se = new SimpleElement();
                                se.setContent(status);

                                List<Availability> list = item.getAvailableOrUnavailable();
                                if( i.getLending_status() != null && i.getLending_status().contains("In Stock")) {
                                    Item.Available available = new Item.Available();
                                    available.setService( DaiaAvailability.LOAN.toString() );
                                    if( duedate != null) available.setDelay(duedate);
                                    List<Object> l = available.getMessageOrLimitation();
                                    l.add( se );
                                    list.add( available );
                                } else { // default availability
                                    Item.Unavailable unavailable = new Item.Unavailable();
                                    if( duedate != null) unavailable.setExpected(duedate);
                                    List<Object> l = unavailable.getMessageOrLimitation();
                                    l.add( se );
                                    list.add(unavailable);
                                }
                                objList.add( item );
                            }
                        }
                    }
                }
            }
            Daia daia = new Daia();
            String daiaVersion = sc.getInitParameter("DAIA_VERSION");
            daia.setVersion( daiaVersion == null ? "0.5" : daiaVersion );
            
            GregorianCalendar gcal = (GregorianCalendar) GregorianCalendar.getInstance();
            XMLGregorianCalendar xgcal = DatatypeFactory.newInstance().newXMLGregorianCalendar(gcal);
            daia.setTimestamp(xgcal);
            
            SimpleElement se = new SimpleElement();
            se.setContent( sc.getInitParameter("INSTITUTION_NAME") );
            se.setHref( sc.getInitParameter("INSTITUTION_URL") );
            daia.setInstitution( se );
            List<Document> docList = daia.getDocument();
            docList.add(daiaDoc);
            JAXBContext jc = JAXBContext.newInstance( Daia.class );
            Marshaller m = jc.createMarshaller();
            m.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
            m.setProperty( Marshaller.JAXB_SCHEMA_LOCATION, "http://ws.gbv.de/daia/ http://ws.gbv.de/daia/daia.xsd");
            StringWriter sw = new StringWriter();
            m.marshal( daia, sw);
            return Response.ok( sw.toString(), "application/xml").build();
        } catch (Exception ex) {
            logger.log(Level.FATAL, "LIBERO DRIVER ERROR", ex);
            throw new WebApplicationException(
                daiaErrorMessage( Response.Status.SERVICE_UNAVAILABLE, "LIBERO DRIVER ERROR: " + ex.getMessage()));
        }
    }
    
    /**
     * Retrieve MARC XML.
     * 
     * @param fincid FINC ID.
     * @return MARC XML data.
     * @throws Exception
     */
    @GET
    @Path("/{fincid: [0-9]+}")
    @Produces("application/xml")
    public Response getMarcXML(@PathParam("fincid") String fincid) throws Exception {
        byte[] marcBlob = getFullRecord(fincid);
        String marcXML = Caller.getMarcXML(marcBlob);
        return Response.ok( marcXML, "application/xml").build();
    }

    /**
     * List all defined namespaces.
     * 
     * @return List of defined namespaces.
     */
    @GET
    @Path("/namespaces")
    @Produces("application/json")
    public String getNamespaces() {
        Set<String> set = getNamespacesList();
        return gson.toJson(set);
    }
    
    /**
     * List of mapped ISIL's.
     * 
     * @return List of mapped ISILs.
     */
    @GET
    @Path("/isils")
    @Produces("application/json")
    public String getIsils() {
        Enumeration<String> e = sc.getInitParameterNames();
        Set ns = new HashSet<>();
        for( ;e.hasMoreElements(); ) {
            String name = e.nextElement();
            if( name.startsWith("ISIL_") ) {
                String s = sc.getInitParameter(name);
                ns.add( gson.fromJson( s, Set.class ) );
            }
        }
        return gson.toJson(ns);
    }
    
    private Set<String> getNamespacesList() {
        Map<String, String> nm = getSolrNsMapping();
        if( nm != null && !nm.isEmpty()) {
            return nm.keySet();
        }
        return gson.fromJson( "[]", Set.class);
    }

    private synchronized String getStylesheet(String resource) throws Exception {

        File file = new File(sc.getResource(resource).toURI());
        if( (file.exists() && file.canRead() && file.lastModified() != time ) ) {
            try (
                BufferedReader br = new BufferedReader(
                    new InputStreamReader(
                        new FileInputStream(file)));
            ) {
                StringBuilder sb = new StringBuilder();
                String line;
                while ( (line = br.readLine()) != null) sb.append(line);
                xslt = sb.toString();
                time = file.lastModified();
            }
        }
        return xslt;
    }
    
    private String buildIsilSubQuery( Collection<String> isilList) {
        
        StringBuilder sb = new StringBuilder();
        if( isilList == null || isilList.isEmpty()) return "";
        for( String isil : isilList) {
            if( sb.length() > 0 )
                sb.append("%20OR%20");
            sb.append("institution:").append(isil);
        }
        if( sb.length() > 0 ) sb.insert( 0, "(").append(")");
        return sb.toString();
    }

    private Set<String> getIsilList( String isil ) {
        for( Enumeration<String> e = sc.getInitParameterNames(); e.hasMoreElements(); ) {
            String name = e.nextElement();
            if( name.startsWith("ISIL_") ) {
                String initParam = sc.getInitParameter(name);
                Set set = gson.fromJson(initParam, Set.class);
                if( set.contains(isil) ) return set;
            }
        }
        Set<String> set = new HashSet<>();
        set.add(isil);
        return set;
    }
    
    private Map<String,String> getSolrNsMapping() {
        String mapping = sc.getInitParameter("SOLR_NS_FIELD");
        if( mapping == null || mapping.trim().isEmpty()) {
            mapping = "{}";
        }
        return gson.fromJson( mapping, Map.class);
    }
    
    private String getOpacId( String isil ) {
        initWebOpacIds();
        return webOpacId.get(isil);
    }
    
    private void initWebOpacIds() {
        synchronized(webOpacId) {
            if( webOpacId.isEmpty() ) { loadWebOpacIds(); }
        }        
    }
    
    private void loadWebOpacIds() {
        if( !webOpacId.isEmpty() ) webOpacId.clear();
        for( Enumeration<String> i = sc.getInitParameterNames(); i.hasMoreElements();) {                
            String e = i.nextElement();
            if( !e.startsWith("ISIL_")) continue;
            String ip = sc.getInitParameter(e);
            Set<String> set = gson.fromJson( ip, Set.class);
            String id = e.substring(5);
            for( String s : set ) {
                webOpacId.put(s, id);
            }
        }
    }

    /**
     * Fetches the MARC blob service url from the configuration.
     * 
     * @return MARC blob service url string.
     */
    private String getMarcBlobUrl() throws Exception {
        
        String marcBlobUrl = sc.getInitParameter( "MARC_BLOB_SERVER_URL" );
        if( marcBlobUrl == null || marcBlobUrl.trim().isEmpty()) {
            String errStr = "MARC_BLOB_SERVER_URL' not defined.";
            logger.fatal(errStr);
            throw new WebApplicationException(
                daiaErrorMessage( Response.Status.SERVICE_UNAVAILABLE, errStr));
        }
        return marcBlobUrl.trim();
    }
    
    /**
     * Fetches a MARC blob from the MARC blob service.
     *
     * @param fincId finc ID.
     * @return MARC blob.
     * @throws Exception 
     */
    private byte[] getFullRecord( String fincId ) throws Exception {
        
        String marcBlobUrl = getMarcBlobUrl();
        String urlStr = String.format(
            "%s%s",
            marcBlobUrl.trim(),
            fincId
        );
        byte[] marcBlob = ApHttpClient.getContent(urlStr);
        if( marcBlob == null || marcBlob.length == 0) {
            String errStr = fincId + " => empty response.";
            logger.fatal(errStr);
            throw new WebApplicationException(
                daiaErrorMessage( Response.Status.NOT_FOUND, errStr) );
        }
        return marcBlob;
    }

    /**
     * Creates a DAIA XML message.
     * 
     * @param status Status code
     * @param errorMessage Message strign
     * @return XML data
     */
    private String daiaMessage( Integer status, String errorMessage) throws Exception {
        Daia daia = new Daia();
        String daiaVersion = sc.getInitParameter("DAIA_VERSION");
        daia.setVersion( daiaVersion == null ? "0.5" : daiaVersion );
        Message message = new Message();
        message.setContent( errorMessage );
        message.setErrno( BigInteger.valueOf( new Long( status) ) );
        daia.getMessage().add(message);

        GregorianCalendar gcal = (GregorianCalendar) GregorianCalendar.getInstance();
        XMLGregorianCalendar xgcal = DatatypeFactory.newInstance().newXMLGregorianCalendar(gcal);
        daia.setTimestamp(xgcal);

        SimpleElement se = new SimpleElement();
        se.setContent( sc.getInitParameter("INSTITUTION_NAME") );
        se.setHref( sc.getInitParameter("INSTITUTION_URL") );
        daia.setInstitution( se );
        JAXBContext jc = JAXBContext.newInstance( Daia.class );
        Marshaller m = jc.createMarshaller();
        m.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
        m.setProperty( Marshaller.JAXB_SCHEMA_LOCATION, SCHEMA_LOCATION);
        StringWriter sw = new StringWriter();
        m.marshal( daia, sw);
        return sw.toString();
    }
    
    /**
     * Creates a DAIA XML error message.
     * 
     * @param status Status code
     * @param errorMessage Message strign
     * @return XML data
     */
    private Response daiaErrorMessage( Response.Status status, String errorMessage) throws Exception {
        Response.ResponseBuilder builder = Response.status(status);
        builder.entity( daiaMessage( status.getStatusCode(), errorMessage ) )
            .header( "Content-Type", "application/xml");
        Response response = builder.build();
        return response;
    }
    
    private Map<String,Map> getAvailabilityList( Map availability ) {
        
        HashMap m = new HashMap();
        
        if( availability != null && !availability.isEmpty()) {
            Object avObj = availability.get("getAvailability");
            if( avObj != null ) {
                List<Map> avList = (List<Map>) avObj;
                if( !avList.isEmpty() ) {
                    for( Map map : avList ) {
                        String bc = (String) map.get("barcode");
                        if( bc != null ) {
                            m.put( bc, map);
                        }
                    }
                }
            }
        }
        
        return m;
    }
    
    private String getDelay( String duedate ) {

        if( duedate != null && !duedate.trim().isEmpty()) {
            try {
                Date  due = new SimpleDateFormat("dd.MM.yyyy").parse(duedate);
                GregorianCalendar dueCal = new GregorianCalendar(TimeZone.getTimeZone("Europe/Berlin"));
                dueCal.setTime(due);
                dueCal.set( Calendar.HOUR, 0);
                dueCal.set( Calendar.MINUTE, 0);
                dueCal.set( Calendar.SECOND, 0);
                dueCal.set( Calendar.MILLISECOND, 0);
                GregorianCalendar nowCal = new GregorianCalendar(TimeZone.getTimeZone("Europe/Berlin"));
                Date  now = new Date();
                nowCal.setTime(now);
                nowCal.set( Calendar.HOUR, 0);
                nowCal.set( Calendar.MINUTE, 0);
                nowCal.set( Calendar.SECOND, 0);
                nowCal.set( Calendar.MILLISECOND, 0);
                Integer days = 0;
                for( Calendar dc = nowCal; dc.before(dueCal); dc.add( Calendar.DATE, 1) ) {
                    days++;
                }
                for( Calendar dc = dueCal; dc.before(nowCal); dc.add( Calendar.DATE, 1) ) {
                    days--;
                }
                if( days != 0 ) return "P" + days + "D";
            } catch( ParseException e ) {
                logger.fatal( duedate, e );
            } 
        }
        
        return null;
    }

}
