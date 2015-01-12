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

import de.unileipzig.de.lbdrv.LiberoDriver;
import java.util.Arrays;
import java.util.concurrent.Callable;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/**
 * Title information and availability with Threading.
 * 
 * @author <a href="mailto:tsolakidis@ub.uni-leipzig.de">Polichronis Tsolakidis</a>
 */
public class DataResultCallable implements Callable<DataResult> {

    private static final Logger logger = Logger.getLogger( DataResultCallable.class );

    private String url;
    private String dbName;
    private String recordId;
    
    public DataResultCallable( String url, String dbName, String recordId) {
        this.url      = url;
        this.dbName   = dbName;
        this.recordId = recordId;
    }

    @Override
    public DataResult call() throws Exception {
        
        final DataResult dataResult = new DataResult();
        // LIBERO DB Zugriff
        Thread t1 = new Thread( new Runnable() {
            @Override
            public void run() {
                try {
                    dataResult.setTo( LiberoDriver.getTitleInformation( url, dbName, recordId) );
                } catch (Exception ex) {
                    logger.log( Level.FATAL, null, ex);
                }
            }
        });
        t1.start();
        Thread t2 = new Thread( new Runnable() {
            @Override
            public void run() {
                try {
                    dataResult.setAvailability( LiberoDriver.getAvailability( url, dbName, Arrays.asList(recordId)) );
                } catch (Exception ex) {
                    logger.log(Level.FATAL, null, ex);
                }
            }
        });
        t2.start();
        
        t1.join();
        t2.join();
        
        return dataResult;
    }

    /**
     * @return the url
     */
    public String getUrl() {
        return url;
    }

    /**
     * @param url the url to set
     */
    public void setUrl(String url) {
        this.url = url;
    }

    /**
     * @return the dbName
     */
    public String getDbName() {
        return dbName;
    }

    /**
     * @param dbName the dbName to set
     */
    public void setDbName(String dbName) {
        this.dbName = dbName;
    }

    /**
     * @return the recordId
     */
    public String getRecordId() {
        return recordId;
    }

    /**
     * @param recordId the recordId to set
     */
    public void setRecordId(String recordId) {
        this.recordId = recordId;
    }

}
