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

package de.unileipzig.ub.linkeddata.solr;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.annotations.SerializedName;
import com.google.gson.reflect.TypeToken;
import java.lang.reflect.Type;
import java.util.List;
import java.util.Map;

/**
 *
 * @author <a href="mailto:tsolakidis@ub.uni-leipzig.de">Polichronis Tsolakidis</a>
 */
public class Doc {

    private static final         Gson gson = new GsonBuilder().setPrettyPrinting().create();
    private static final Type mapItemDataType = new TypeToken<Map<String,List<ItemData>>>() {}.getType();
    
    private String id;
    @SerializedName("record_id")
    private String recordId;
    private String zdb;
    private String fullrecord;
    @SerializedName("signatur")
    private List<String> callnumber;
    private List<String> barcode;
    @SerializedName("itemdata")
    private String itemData;
    @SerializedName("source_id")
    private Integer sourceId;

    /**
     * @return the fullrecord
     */
    public String getFullrecord() {
        return fullrecord;
    }

    /**
     * @param fullrecord the fullrecord to set
     */
    public void setFullrecord( String fullrecord) {
        this.fullrecord = fullrecord;
    }

    /**
     * @return the id
     */
    public String getId() {
        return id;
    }

    /**
     * @param id the id to set
     */
    public void setId(String id) {
        this.id = id;
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

    /**
     * @return the zdb
     */
    public String getZdb() {
        return zdb;
    }

    /**
     * @param zdb the zdb to set
     */
    public void setZdb(String zdb) {
        this.zdb = zdb;
    }

    /**
     * @return the callnumber
     */
    public List<String> getCallnumber() {
        return callnumber;
    }

    /**
     * @param callnumber the callnumber to set
     */
    public void setCallnumber(List<String> callnumber) {
        this.callnumber = callnumber;
    }

    /**
     * @return the barcode
     */
    public List<String> getBarcode() {
        return barcode;
    }

    /**
     * @param barcode the barcode to set
     */
    public void setBarcode(List<String> barcode) {
        this.barcode = barcode;
    }

    /**
     * @return the itemData
     */
    public String getItemData() {
        return itemData;
    }

    /**
     * @param itemData the itemData to set
     */
    public void setItemData(String itemData) {
        this.itemData = itemData;
    }

    public Map<String,List<ItemData>> toItemDataObject() {
        
        if( itemData != null && !itemData.isEmpty()) {
            return gson.fromJson( itemData, mapItemDataType);
        }
        return null;
    }

    /**
     * @return the sourceId
     */
    public Integer getSourceId() {
        return sourceId;
    }

    /**
     * @param sourceId the sourceId to set
     */
    public void setSourceId(Integer sourceId) {
        this.sourceId = sourceId;
    }
}
