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

package de.unileipzig.ub.linkeddata;

import java.io.StringWriter;
import java.util.Collection;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import org.w3c.dom.Node;

/**
 * Some helper methods.
 * 
 * @author <a href="mailto:tsolakidis@ub.uni-leipzig.de">Polichronis Tsolakidis</a>
 */
public class Helper {

    /**
     * Convert a DOM node to XML.
     * 
     * @param node Node.
     * @return XML.
     */
    public static String asXml( Node node) {
        try {
            TransformerFactory f = TransformerFactory.newInstance();
            Transformer transformer = f.newTransformer();
            
            transformer.setOutputProperty( OutputKeys.INDENT, "yes");

            DOMSource domsource = new DOMSource(node);
            StringWriter sw = new StringWriter();
            StreamResult sr = new StreamResult(sw);
            transformer.transform(domsource, sr);
            return sw.toString();
        } catch( Exception ex) {
            throw new RuntimeException(ex);
        }
    }

    /**
     * Join strings.
     * 
     * @param data List of strings.
     * @param delim Delimiter.
     * @return The joined string.
     */
    public static String join( Collection<String> data, String delim) {
        StringBuilder sb = new StringBuilder();
        for( String s : data ) {
            sb.append( sb.length() > 0 ? delim : "")
                .append(s);
        }
        return sb.toString();
    }

}
