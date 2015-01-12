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
package de.unileipzig.de.lbdrv;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import de.unileipzig.ub.linkeddata.http.client.ApHttpClient;
import java.net.URLEncoder;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.unileipzig.ub.libero.cacheupdater.json.TitleInformationObject;

/**
 * http://139.18.19.239:8080/solr/biblio/select?q=id:0002345433&wt=json&fl=fullrecord,id,record_id,signatur,barcode,itemdata
 * 
 * @author <a href="mailto:tsolakidis@ub.uni-leipzig.de">Polichronis Tsolakidis</a>
 */
public class LiberoDriver {

    private static final     Gson gson = new GsonBuilder().setPrettyPrinting().create();
    
    public static TitleInformationObject getTitleInformation( String baseUrl, String dbName, String ppn) throws Exception {
        StringBuilder sb = new StringBuilder();
        sb.append( baseUrl ).append( baseUrl.endsWith("/") ? "" : "/" )
            .append("getTitleInformation.jsp")
            .append("?")
            .append("dbName")
            .append("=")
            .append(URLEncoder.encode(dbName, "UTF-8"))
            .append("&")
            .append("recordIds")
            .append("=")
            .append(URLEncoder.encode(ppn, "UTF-8"));

        byte[] buff = ApHttpClient.getContent( sb.toString() );

        String content = new String( buff, "UTF-8");
        if( !content.trim().isEmpty()) {
            TitleInformationObject o = gson.fromJson( content, TitleInformationObject.class);
            o.setDbName(dbName);
            return o;
        }
        return null;
    }
    
    /**
     * Gets the availability of a list of PPN.
     * 
     * @param baseUrl Liberoding URL
     * @param dbName Library id
     * @param rids List of PPN
     * @return Avalability map.
     * @throws Exception 
     */
    public static Map getAvailability( String baseUrl, String dbName, List<String> rids) throws Exception {
        
        StringBuilder ridBuilder = new StringBuilder();
        for( String s : rids ) {
            ridBuilder.append( ridBuilder.length() > 0 ? "," : "")
                .append(s);
        }

        StringBuilder sb = new StringBuilder();
        sb.append( baseUrl ).append( baseUrl.endsWith("/") ? "" : "/" )
            .append("getAvailability.jsp")
            .append("?")
            .append("dbName")
            .append("=")
            .append(URLEncoder.encode(dbName, "UTF-8"))
            .append("&")
            .append("recordId")
            .append("=")
            .append(URLEncoder.encode(ridBuilder.toString(), "UTF-8"));
        byte[] buff = ApHttpClient.getContent( sb.toString() );
        String content = new String( buff, "UTF-8");
        if( !content.trim().isEmpty()) {
            Map result = gson.fromJson( content, Map.class);
            return result;
        }
        return null;
    }
    
    public static Map getSimpleAvailability( String baseUrl, String dbName, List<String> recordIds) throws Exception {
        
        StringBuilder ridBuilder = new StringBuilder();
        for( String s : recordIds ) {
            ridBuilder.append( ridBuilder.length() > 0 ? "," : "")
                .append(s);
        }
        
        StringBuilder sb = new StringBuilder();
        sb.append( baseUrl ).append( baseUrl.endsWith("/") ? "" : "/" )
            .append("getSimpleAvailability.jsp")
            .append("?")
            .append("dbName")
            .append("=")
            .append(URLEncoder.encode(dbName, "UTF-8"))
            .append("&")
            .append("recordIds")
            .append("=")
            .append(URLEncoder.encode(ridBuilder.toString(), "UTF-8"));
        byte[] buff = ApHttpClient.getContent( sb.toString() );
        String content = new String( buff, "UTF-8");
        if( !content.trim().isEmpty()) {
            Map result = gson.fromJson( content, Map.class);
            Map ret = new LinkedHashMap();
            Object get = result.get("getAvailability");
            if( get != null ) {
                Map avMap = (Map) get;
                if( avMap.size() > 0 ) {
                    for( Object k : avMap.keySet()) {
                        Map bc = (Map) avMap.get(k.toString());
                        if( bc.containsKey("barcodes") ) {
                            Map barcodes = (Map) bc.get("barcodes");
                            for( Object kk : barcodes.keySet()) {
                                ret.put(kk, barcodes.get(kk));
                            }
                        }
                    }
                }
            }
            return ret;
        }
        return null;
    }
}
