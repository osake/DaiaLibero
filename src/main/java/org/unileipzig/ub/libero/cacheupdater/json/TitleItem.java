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

import java.util.Collections;
import java.util.List;
import org.apache.commons.collections.ListUtils;
import org.apache.commons.lang3.builder.HashCodeBuilder;

/**
 * Klasse zum Serialisieren/Deserialisieren von JSON.
 * 
 * @author <a href="mailto:tsolakidis@ub.uni-leipzig.de">Polichronis Tsolakidis</a>
 */
public class TitleItem {

    /**
     * Liste der zusätzlichen Signaturen.
     * {@link #call_number}
     */
    private List<String> additional_call_numbers;
    
    /**
     * Exemplarstandort.
     */
    private String owner_branch;
    
    /**
     * Hauptsignatur.
     */
    private String call_number;
    
    /**
     * Anzahl zusätzlicher Signaturen.
     */
    private String cn_count;
    
    /**
     * Literaturabteilung.
     */
    private String collection_code;
    
    /**
     * Barcode.
     */
    private String barcode;
    
    /**
     * Zweigstelle.
     */
    private String branch_at;
    
    /**
     * Exemplarstatuscode.
     */
    private String exception_code;
    
    /**
     * Verfügbarkeit.
     */
    private String lending_status;

    /**
     * @return the additional_call_numbers
     */
    public List<String> getAdditional_call_numbers() {
        return additional_call_numbers;
    }

    /**
     * @param additional_call_numbers the additional_call_numbers to set
     */
    public void setAdditional_call_numbers(List<String> additional_call_numbers) {
        this.additional_call_numbers = additional_call_numbers;
    }

    /**
     * @return the owner_branch
     */
    public String getOwner_branch() {
        return owner_branch;
    }

    /**
     * @param owner_branch the owner_branch to set
     */
    public void setOwner_branch(String owner_branch) {
        this.owner_branch = owner_branch;
    }

    /**
     * @return the call_number
     */
    public String getCall_number() {
        return call_number;
    }

    /**
     * @param call_number the call_number to set
     */
    public void setCall_number(String call_number) {
        this.call_number = call_number;
    }

    /**
     * @return the cn_count
     */
    public String getCn_count() {
        return cn_count;
    }

    /**
     * @param cn_count the cn_count to set
     */
    public void setCn_count(String cn_count) {
        this.cn_count = cn_count;
    }

    /**
     * @return the collection_code
     */
    public String getCollection_code() {
        return collection_code;
    }

    /**
     * @param collection_code the collection_code to set
     */
    public void setCollection_code(String collection_code) {
        this.collection_code = collection_code;
    }

    /**
     * @return the barcode
     */
    public String getBarcode() {
        return barcode;
    }

    /**
     * @param barcode the barcode to set
     */
    public void setBarcode(String barcode) {
        this.barcode = barcode;
    }

    /**
     * @return the branch_at
     */
    public String getBranch_at() {
        return branch_at;
    }

    /**
     * @param branch_at the branch_at to set
     */
    public void setBranch_at(String branch_at) {
        this.branch_at = branch_at;
    }

    /**
     * @return the exception_code
     */
    public String getException_code() {
        return exception_code;
    }

    /**
     * @param exception_code the exception_code to set
     */
    public void setException_code(String exception_code) {
        this.exception_code = exception_code;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final TitleItem other = (TitleItem) obj;
        if (this.additional_call_numbers != other.additional_call_numbers && (this.additional_call_numbers == null || !this.additional_call_numbers.equals(other.additional_call_numbers))) {
            return false;
        }
        if ((this.owner_branch == null) ? (other.owner_branch != null) : !this.owner_branch.equals(other.owner_branch)) {
            return false;
        }
        if ((this.call_number == null) ? (other.call_number != null) : !this.call_number.equals(other.call_number)) {
            return false;
        }
        if ((this.cn_count == null) ? (other.cn_count != null) : !this.cn_count.equals(other.cn_count)) {
            return false;
        }
        if ((this.collection_code == null) ? (other.collection_code != null) : !this.collection_code.equals(other.collection_code)) {
            return false;
        }
        if ((this.barcode == null) ? (other.barcode != null) : !this.barcode.equals(other.barcode)) {
            return false;
        }
        if ((this.branch_at == null) ? (other.branch_at != null) : !this.branch_at.equals(other.branch_at)) {
            return false;
        }
        if ((this.exception_code == null) ? (other.exception_code != null) : !this.exception_code.equals(other.exception_code)) {
            return false;
        }
        if(this.additional_call_numbers != null && other.additional_call_numbers != null) {
            Collections.sort(this.additional_call_numbers);
            Collections.sort(other.additional_call_numbers);
            if(!ListUtils.isEqualList(this.additional_call_numbers, other.additional_call_numbers)) {
                return false;
            }
        }
        return true;
    }

    @Override
    public int hashCode() {
        int hash = new HashCodeBuilder(1,3).append(call_number).append(barcode).toHashCode();
        hash = 67 * hash + (this.additional_call_numbers != null ? this.additional_call_numbers.hashCode() : 0);
        hash = 67 * hash + (this.owner_branch != null ? this.owner_branch.hashCode() : 0);
        hash = 67 * hash + (this.call_number != null ? this.call_number.hashCode() : 0);
        hash = 67 * hash + (this.barcode != null ? this.barcode.hashCode() : 0);
        hash = 67 * hash + (this.exception_code != null ? this.exception_code.hashCode() : 0);
        return hash;
    }

    /**
     * @return the lending_status
     */
    public String getLending_status() {
        return lending_status;
    }

    /**
     * @param lending_status the lending_status to set
     */
    public void setLending_status(String lending_status) {
        this.lending_status = lending_status;
    }
    
    
}
