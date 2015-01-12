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

import java.util.List;

/**
 *
 * @author <a href="mailto:tsolakidis@ub.uni-leipzig.de">Polichronis Tsolakidis</a>
 */
public class Response {

    private Integer   numFound;
    private List<Doc> docs;

    /**
     * @return the numFound
     */
    public Integer getNumFound() {
        return numFound;
    }

    /**
     * @param numFound the numFound to set
     */
    public void setNumFound(Integer numFound) {
        this.numFound = numFound;
    }

    /**
     * @return the docs
     */
    public List<Doc> getDocs() {
        return docs;
    }

    /**
     * @param docs the docs to set
     */
    public void setDocs(List<Doc> docs) {
        this.docs = docs;
    }
}
