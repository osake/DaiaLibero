/*
 * 2015 Leipzig University Library, http://www.ub.uni-leipzig.de
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
 */

package de.gbv.ws.daia;

/**
 * Service Namen in DAIA.
 * 
 * <p>
 * Information
 * <a href="http://www.gbv.de/wikis/cls/DAIA_-_Document_Availability_Information_API">DAIA</a>
 * </p>
 * 
 * @author <a href="mailto:tsolakidis@ub.uni-leipzig.de">Polichronis Tsolakidis</a>
 */
public enum DaiaAvailability {

    PRESENTATION ( "presentation" ),
    LOAN         ( "loan" ),
    OPENACCESS   ( "openaccess" ),
    INTERLOAN    ( "interloan" ),
    UNSPECIFIED  ( "unspecified" );
    
    private final String name;
    private DaiaAvailability( String name ) { this.name = name; };
    public boolean equalsName( String otherName ) {
        return ( otherName == null ) ? false : name.equals( otherName );
    }
    @Override
    public String toString() { return name; }
}
