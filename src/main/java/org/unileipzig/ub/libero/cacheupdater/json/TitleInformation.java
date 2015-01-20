/*
 * 2012 Leipzig University Library, http://www.ub.uni-leipzig.de
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
 * http://finc.info Project finc, finc@ub.uni-leipzig.de
 */

package org.unileipzig.ub.libero.cacheupdater.json;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import org.apache.commons.collections.ListUtils;
import org.apache.commons.lang3.builder.HashCodeBuilder;

/**
 * Klasse zum Serialisieren/Deserialisieren von JSON.
 * 
 * @author <a href="mailto:tsolakidis@ub.uni-leipzig.de">Polichronis Tsolakidis</a>
 */
public class TitleInformation {

    /**
     * Liste der Exemplare.
     */
    private List<TitleItem> title_items;
    
    /**
     * Anzeigeunterdrückungsflag. :-)
     */
    private String opac_display_flag;
    
    /**
     * PPN
     */
    private String rid;
    
    /**
     * RSN
     */
    private String rsn;
    
    /**
     * MAB Daten.
     */
    private Map<String,List<String>> mab_data;

    /**
     * @return the title_items
     */
    public List<TitleItem> getTitle_items() {
        return title_items;
    }

    /**
     * @param title_items the title_items to set
     */
    public void setTitle_items(List<TitleItem> title_items) {
        this.title_items = title_items;
    }

    /**
     * @return the opac_display_flag
     */
    public String getOpac_display_flag() {
        return opac_display_flag;
    }

    /**
     * @param opac_display_flag the opac_display_flag to set
     */
    public void setOpac_display_flag(String opac_display_flag) {
        this.opac_display_flag = opac_display_flag;
    }

    /**
     * @return the rid
     */
    public String getRid() {
        return rid;
    }

    /**
     * @param rid the rid to set
     */
    public void setRid(String rid) {
        this.rid = rid;
    }

    /**
     * @return the rsn
     */
    public String getRsn() {
        return rsn;
    }

    /**
     * @param rsn the rsn to set
     */
    public void setRsn(String rsn) {
        this.rsn = rsn;
    }

    /**
     * @return the mab_data
     */
    public Map<String,List<String>> getMab_data() {
        return mab_data;
    }

    /**
     * @param mab_data the mab_data to set
     */
    public void setMab_data(Map<String,List<String>> mab_data) {
        this.mab_data = mab_data;
    }

    @Override
    public boolean equals(Object obj) {
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final TitleInformation other = (TitleInformation) obj;
        if (this.title_items != other.title_items && (this.title_items == null || !this.title_items.equals(other.title_items))) {
            return false;
        }
        if ((this.opac_display_flag == null) ? (other.opac_display_flag != null) : !this.opac_display_flag.equals(other.opac_display_flag)) {
            return false;
        }
        if ((this.rid == null) ? (other.rid != null) : !this.rid.equals(other.rid)) {
            return false;
        }
        if ((this.rsn == null) ? (other.rsn != null) : !this.rsn.equals(other.rsn)) {
            return false;
        }

        if(this.mab_data != null && other.mab_data != null) {
            for( String s : this.mab_data.keySet()) {
                List<String> get1 = this.mab_data.get(s);
                Collections.sort(get1);
                List<String> get2 = other.mab_data.get(s);
                if(get2 == null) return false;
                Collections.sort(get2);
                if(!ListUtils.isEqualList(get1, get2)) {
                    return false;
                }
            }
        }
        
        if (this.mab_data != other.mab_data && (this.mab_data == null || !this.mab_data.equals(other.mab_data))) {
            return false;
        }
        
        return true;
    }

    @Override
    public int hashCode() {
        return new HashCodeBuilder(1,3).append(rid).append(rsn).toHashCode();
    }

}
