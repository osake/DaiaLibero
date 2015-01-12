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

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *
 * @author <a href="mailto:tsolakidis@ub.uni-leipzig.de">Polichronis Tsolakidis</a>
 */
public class Barcode {

    private static final Pattern p = Pattern.compile("^(\\(\\S+\\))(\\S+)$");
    
    private String isil;
    private String barcode;

    public Barcode( String solrBarcode ) {
        Matcher matcher = p.matcher( solrBarcode);
        if( matcher.find()) {
               isil = matcher.group(1);
            barcode = matcher.group(2);
        } else {
            throw new IllegalArgumentException("Unknown barcode format.");
        }
    }

    /**
     * @return the isil
     */
    public String getIsil() {
        return isil;
    }

    /**
     * @param isil the isil to set
     */
    public void setIsil(String isil) {
        this.isil = isil;
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

}
