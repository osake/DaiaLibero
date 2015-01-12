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

package de.unileipzig.ub.linkeddata.http.client;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import de.unileipzig.ub.linkeddata.solr.Doc;
import de.unileipzig.ub.linkeddata.solr.Response;
import de.unileipzig.ub.linkeddata.solr.SolrResponse;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.List;
import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import org.apache.http.HttpEntity;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;
import org.apache.log4j.Logger;

/**
 * Apache Http Components Client.
 * 
 * @author <a href="mailto:tsolakidis@ub.uni-leipzig.de">Polichronis Tsolakidis</a>
 */
public class ApHttpClient implements ServletContextListener {
    
    private static final Logger logger = Logger.getLogger( ApHttpClient.class);
    private static final PoolingHttpClientConnectionManager m = new PoolingHttpClientConnectionManager();
    private static final CloseableHttpClient httpClient;
    static {
        logger.info("HTTP CLIENT CLASS => INITIALIZE");
        m.setMaxTotal(100);
        m.setDefaultMaxPerRoute(14);
        httpClient = HttpClients.custom()
            .setConnectionManager(m)
            .build();
    }
    
    private static final Integer BUFFSIZE = 1024 * 8;
    private static final Gson        gson = new GsonBuilder().setPrettyPrinting().create();

    @Override
    public void contextInitialized(ServletContextEvent event) {
        logger.info("SERVLETCONTEXT => HTTP CLIENT INITIALIZE OK");
    }

    @Override
    public void contextDestroyed(ServletContextEvent event) {
        logger.info("SERVLETCONTEXT => HTTP CLIENT SHUTDOWN");
        m.shutdown();
    }

    public static final CloseableHttpClient getHttpClient() {
        return httpClient;
    }
    
    public static byte[] getContent( URL url ) throws URISyntaxException, IOException {
        
        try ( ByteArrayOutputStream bao = new ByteArrayOutputStream(); ) {

            HttpGet httpGet = new HttpGet( url.toURI());
            try( CloseableHttpResponse response = ApHttpClient.getHttpClient().execute(httpGet); ) {

                Integer code = response.getStatusLine().getStatusCode();

                if( code == 200 ) {

                    HttpEntity entity = response.getEntity();

                    byte[] buff = new byte[BUFFSIZE];
                    int c;
                    try ( InputStream is = entity.getContent(); ) {
                        while((c = is.read(buff)) != -1) {
                            bao.write(buff, 0, c);
                        }
                    }
                } else {
                    logger.warn(
                        String.format( "SWB+ HTTP Client: Resource %s returns HTTP status %s", url.toString(), code.toString())
                    );
                }
            }
            
            return bao.toByteArray();
        
        } catch( IOException e) {
            logger.info(
                String.format( "SWB+ HTTP Client: %s => %s", e.getMessage(), url.toString())
            );
            throw e;
        }
    }
    
    public static byte[] getContent( String url) throws URISyntaxException, MalformedURLException, IOException {
        return getContent( new URL(url) );
    }

    public static String getContent( String url, String charset) throws URISyntaxException, MalformedURLException, IOException {
        return new String( getContent( new URL(url) ), charset);
    }

    public static Doc solrCall( String url ) throws URISyntaxException, MalformedURLException, IOException {
        byte[] data = getContent( new URL(url).toString() );
        String content = new String( data, "UTF-8");
        SolrResponse solrResponse = gson.fromJson( content, SolrResponse.class);
        Response response = solrResponse.getResponse();
        if( response != null) {
            List<Doc> docs = response.getDocs();
            if( docs != null && docs.size() > 0) {
                Doc doc = docs.get(0);
                if( doc != null) {
                    return doc;
                }
            }
        }
        return null;
    }
}
