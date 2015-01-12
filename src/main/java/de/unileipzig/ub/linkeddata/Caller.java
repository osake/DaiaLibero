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

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.StringReader;
import java.io.StringWriter;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.marc4j.MarcReader;
import org.marc4j.MarcStreamReader;
import org.marc4j.MarcWriter;
import org.marc4j.MarcXmlWriter;
import org.marc4j.marc.Record;

/**
 *
 * @author <a href="mailto:tsolakidis@ub.uni-leipzig.de">Polichronis
 * Tsolakidis</a>
 */
public class Caller {

    private static final TransformerFactory tFactory = TransformerFactory.newInstance();
    private static final            Integer BUFFSIZE = 1024 * 8;

    /*
     * http://www.stylusstudio.com/xsllist/200306/post60400.html
     * http://www.xmlprime.com/xmlprime/doc/2.6/serialization-parameters.htm
     * http://projects.freelibrary.info/freelib-marc4j/tutorial.html
     *
     * http://www.cafeconleche.org/books/xmljava/chapters/ch17.html
     */

    /**
     * Convert binary MARC to MARC XML.
     * 
     * @param marcData Binary MARC data.
     * @return Marc XML.
     * @throws Exception 
     */
    public static String getMarcXML( byte[] marcData ) throws Exception {

        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        try (ByteArrayInputStream bais = new ByteArrayInputStream(marcData);) {
            MarcReader reader = new MarcStreamReader( bais );
            MarcWriter writer = new MarcXmlWriter( bos, true);

//            AnselToUnicode converter = new AnselToUnicode();
//            writer.setConverter(converter);

            while (reader.hasNext()) {
                Record record = reader.next();
                writer.write(record);
            }
            try { writer.close(); } catch (Exception e) {}
        }

        Transformer transformer = tFactory.newTransformer();
        transformer.setOutputProperty(OutputKeys.INDENT, "yes");

        StringWriter sw = new StringWriter();
        StreamResult sr = new StreamResult(sw);

        transformer.transform( new StreamSource(new StringReader(new String( bos.toByteArray() ))), sr);
        return sw.toString();
    }
    
    public static String toRDF( byte[] marcData, String xslt) throws Exception {

        StringWriter rdf = new StringWriter();
        try (ByteArrayInputStream bais = new ByteArrayInputStream(marcData);) {
            StreamSource s1 = new StreamSource(new StringReader(xslt));
            MarcReader reader = new MarcStreamReader( bais );
            MarcWriter writer = new MarcXmlWriter( new StreamResult(rdf), s1);

//            AnselToUnicode converter = new AnselToUnicode();
//            writer.setConverter(converter);

            while (reader.hasNext()) {
                Record record = reader.next();
                writer.write(record);
            }
            try { writer.close(); } catch (Exception e) {}
        }        
        return rdf.toString();
    }
    

}
