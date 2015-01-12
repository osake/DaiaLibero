/*
 * Copyright (C) 2012 Polichronis Tsolakidis
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

package org.unileipzig.ub.libero.cacheupdater.json;

import java.util.Map;

/**
 * Klasse zum Serialisieren/Deserialisieren von JSON.
 * 
 * <p>Diese Klass bildet die JSON Daten aus <i>getTitleInformation</i> ab.</p>
 * 
 * @author <a href="mailto:tsolakidis@ub.uni-leipzig.de">Polichronis Tsolakidis</a>
 */
public class TitleInformationObject {

    /**
     * Assoziatives Array mit Titeln. Kann auch leer sein.
     */
    private Map<String,TitleInformation> getTitleInformation;
    
    /**
     * Bibliotheks id.
     */
    private String dbName;
    
    /**
     * Fehlercode.
     */
    private int errorcode;
    
    private transient String time;
    
    /**
     * Hier steht die Fehlermeldung drin wenn errorcode <> 0.
     */
    private String errormessage;

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
     * @return the errorcode
     */
    public int getErrorcode() {
        return errorcode;
    }

    /**
     * @param errorcode the errorcode to set
     */
    public void setErrorcode(int errorcode) {
        this.errorcode = errorcode;
    }

    /**
     * @return the time
     */
    public String getTime() {
        return time;
    }

    /**
     * @param time the time to set
     */
    public void setTime(String time) {
        this.time = time;
    }

    /**
     * @return the getTitleInformation
     */
    public Map<String,TitleInformation> getGetTitleInformation() {
        return getTitleInformation;
    }

    /**
     * @param getTitleInformation the getTitleInformation to set
     */
    public void setGetTitleInformation(Map<String,TitleInformation> getTitleInformation) {
        this.getTitleInformation = getTitleInformation;
    }

    /**
     * @return the errormessage
     */
    public String getErrormessage() {
        return errormessage;
    }

    /**
     * @param errormessage the errormessage to set
     */
    public void setErrormessage(String errormessage) {
        this.errormessage = errormessage;
    }
    
}
