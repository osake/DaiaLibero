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

package de.gbv.ws.daia.availability;

import de.gbv.ws.daia.Availability;
import de.gbv.ws.daia.Item;
import java.net.URL;

/**
 * Verfügbarkeit.
 * 
 * @author <a href="mailto:tsolakidis@ub.uni-leipzig.de">Polichronis Tsolakidis</a>
 */
public class LiberoAvailability {

    private Availability available;
    private       String ppn;
    
    private LiberoAvailability( URL liberoBaseURL, String ppn) {
        this.ppn = ppn;
    }

    public LiberoAvailability getAvailability( String url, String ppn) throws Exception {
        return new LiberoAvailability( new URL(url), ppn);
    }

    /**
     * @return the available
     */
    public Availability getAvailable() {
        return available != null ? available : new Item.Unavailable();
    }

    /**
     * @param available the available to set
     */
    public void setAvailable(Availability available) {
        this.available = available;
    }

    /**
     * @return the ppn
     */
    public String getPpn() {
        return ppn;
    }
}
