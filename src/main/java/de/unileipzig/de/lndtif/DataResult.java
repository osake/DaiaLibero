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

import java.util.Map;
import org.unileipzig.ub.libero.cacheupdater.json.TitleInformationObject;

/**
 * A holder for title informations.
 * 
 * @author <a href="mailto:tsolakidis@ub.uni-leipzig.de">Polichronis Tsolakidis</a>
 */
public class DataResult {

    private TitleInformationObject to;
    private Map availability;

    /**
     * @return the to
     */
    public TitleInformationObject getTo() {
        return to;
    }

    /**
     * @param to the to to set
     */
    public void setTo(TitleInformationObject to) {
        this.to = to;
    }

    /**
     * @return the availability
     */
    public Map getAvailability() {
        return availability;
    }

    /**
     * @param availability the availability to set
     */
    public void setAvailability(Map availability) {
        this.availability = availability;
    }
}
