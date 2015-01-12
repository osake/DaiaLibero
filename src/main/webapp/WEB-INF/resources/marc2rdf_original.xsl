<?xml version="1.0" encoding="UTF-8"?>
<!--
    Document   : marc2rdf.xsl
    Description: Transforms MARCXML to RDF/XML.
    Author     : Bayerische Staatsbibliothek <lod@bsb-muenchen.de>
    License    : CC0 <http://creativecommons.org/publicdomain/zero/1.0/>
    
    Some parts of this XSL can only be used with Java's Xalan processor and the 
    appropriate extension classes. Anyway you could just remove all occurrences of
    the ext:-Namespace. Some of the ext:-Tags can be substituted with XSLT 2.0.
    
    Additionally a special preprocessing is needed for MARC's controlfields and leader. 
    In our solution we just fill all Spaces with the letter 'ä' to preserve positions.
    @.@  
    
    ToDo: Remove duplicate triples e.g. from dct:subject. When importing the data
    into a TripleStore, this deduplication will be performed automatically. 
-->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dct="http://purl.org/dc/terms/"
    xmlns:dcmitype="http://purl.org/dc/dcmitype/"
    xmlns:bibo="http://purl.org/ontology/bibo/"
    xmlns:frbr="http://purl.org/vocab/frbr/core#"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:geonames="http://www.geonames.org/ontology#"
    xmlns:rdagr1="http://rdvocab.info/Elements/"
    xmlns:marcrel="http://id.loc.gov/vocabulary/relators/"
    xmlns:isbd="http://iflastandards.info/ns/isbd/elements/"
    xmlns:ext="xalan://de.bsb_muenchen.marc2rdf.xsltfunctions.XsltFunctions"
    xmlns:marc="http://www.loc.gov/MARC21/slim"
    exclude-result-prefixes="xsl marc xalan ext rdf rdfs owl dc dct dcmitype bibo marc frbr foaf skos geonames rdagr1 marcrel isbd" 
    extension-element-prefixes="ext"
    version="1.0"><!-- rdf rdfs owl dc dct dcmitype bibo marc frbr foaf skos geonames rdagr1 marcrel isbd"-->
   
    <xsl:output method="xml" encoding="UTF-8" indent="no" omit-xml-declaration="yes" standalone="yes"/>

    <!-- General Settings -->
    <xsl:param name="uriPrefix">
        <xsl:text>http://lod.b3kat.de/</xsl:text>
    </xsl:param>
    <xsl:param name="bibUriPrefix">
        <xsl:text>http://lod.b3kat.de/bib/</xsl:text>
    </xsl:param>
    <xsl:param name="docIdUriPrefix">
        <xsl:value-of select="concat($uriPrefix, 'title/')" />
    </xsl:param>
    <xsl:param name="isbnUriPrefix">
        <xsl:value-of select="concat($uriPrefix, 'isbn/')" />
    </xsl:param>
    <xsl:param name="issnUriPrefix">
        <xsl:value-of select="concat($uriPrefix, 'issn/')" />
    </xsl:param>
    <xsl:param name="rvkUriPrefix">
        <xsl:value-of select="concat($uriPrefix, 'rvk/')" />
    </xsl:param>
    <xsl:param name="ssgUriPrefix">
        <xsl:value-of select="concat($uriPrefix, 'ssg/')" />
    </xsl:param>
    <xsl:param name="docId">
        <xsl:value-of select="//marc:controlfield[@tag='001']/text()" />
    </xsl:param>
    <xsl:param name="sparqlEndpoint">
        <xsl:text>http://triples10.bsb-muenchen.int/</xsl:text>
    </xsl:param>
    <xsl:param name="sparqlEndpointLCSH">
        <xsl:value-of select="concat($sparqlEndpoint, 'SparqlProxy/sparql_lcsh')" />
    </xsl:param>
    <xsl:param name="sparqlEndpointBibData">
        <xsl:value-of select="concat($sparqlEndpoint, 'SparqlProxy/sparql_b3kat')" />
    </xsl:param>
    <xsl:param name="gndUriPrefix">
        <xsl:text>http://d-nb.info/gnd/</xsl:text>
    </xsl:param>
    <xsl:param name="titleUri">
        <xsl:value-of select="concat($docIdUriPrefix,$docId)" />
    </xsl:param>

    <xsl:template match="/">
        <xsl:if test="string-length($docId) > 1">
            <xsl:call-template name="mainMapping"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="mainMapping">
        <rdf:Description rdf:about="{$titleUri}">
           
            <!-- MediaTypeDetection -->
            <xsl:for-each select="//marc:leader">
                <xsl:choose>
                    <!-- Combination of media - this must be put first, because otherwise one of the contained single media types would be detected -->
                    <xsl:when test="substring(.,7,1) = 'p' or substring(.,7,1) = 'o' or substring(//marc:controlfield[@tag='006'],1,1) = 'o' or substring(//marc:controlfield[@tag='006'],1,1) = 'p' or substring(//marc:controlfield[@tag='007'],1,1) = 'o'">
                        <rdf:type rdf:resource="http://purl.org/dc/dcmitype/Collection" />
                    </xsl:when>
                </xsl:choose>
                    
                <!-- Series -->
                <xsl:choose>
                    <xsl:when test="substring(.,7,1) = 'a' and substring(.,8,1) = 's' and substring(//marc:controlfield[@tag='008'],22,1) = 'm'">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Series" />
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='006'],1,1) = 's' and substring(//marc:controlfield[@tag='006'],5,1) = 'm'">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Series" />
                    </xsl:when>
                </xsl:choose>
                    
                <!-- Periodical -->
                <xsl:choose>
                    <xsl:when test="substring(.,7,1) = 'a' and substring(.,8,1) = 's' and substring(//marc:controlfield[@tag='008'],22,1) = 'p'"> 
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Periodical" />
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='006'],1,1) = 's' and substring(//marc:controlfield[@tag='006'],5,1) = 'p'">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Periodical" />
                    </xsl:when>
                </xsl:choose>
                    
                <!-- Newspaper -->
                <xsl:choose>
                    <xsl:when test="substring(.,7,1) = 'a' and substring(.,8,1) = 's' and substring(//marc:controlfield[@tag='008'],22,1) = 'n'">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Newspaper" />
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='006'],1,1) = 's' and substring(//marc:controlfield[@tag='006'],5,1) = 'n'">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Newspaper" />
                    </xsl:when>
                </xsl:choose>
                    
                <!-- Manuscript -->
                <xsl:choose>
                    <xsl:when test="substring(.,7,1) = 't' or substring(//marc:controlfield[@tag='006'],1,1) = 't'">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Manuscript" />
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='006'],1,1) = 't'">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Manuscript" />
                    </xsl:when>
                </xsl:choose>
                    
                <!-- MultiVolumeBook -->
                <xsl:choose>
                    <xsl:when test="substring(.,8,1) = 'm' and substring(.,20,1) = 'a'">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/MultiVolumeBook" />
                    </xsl:when>
                </xsl:choose>
                    
                <!-- Monograph -->
                <xsl:choose>
                    <xsl:when test="substring(.,8,1) = 'm' and substring(//marc:controlfield[@tag='008'],7,1) = 's'">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Book" />
                    </xsl:when>
                </xsl:choose>
                    
                <!-- Microform -->
                <xsl:choose>
                    <xsl:when test="substring(//marc:controlfield[@tag='007'],1,1) = 'h'">
                        <rdf:type rdf:resource="http://rdvocab.info/termList/RDAMediaType/1002" />
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='006'],1,1) = 'r'">
                        <xsl:if test="substring(//marc:controlfield[@tag='006'],7,1) = 'a' or substring(//marc:controlfield[@tag='006'],7,1) = 'b'">
                            <rdf:type rdf:resource="http://rdvocab.info/termList/RDAMediaType/1002" />
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='006'],1,1) = 'a' 
                                    or substring(//marc:controlfield[@tag='006'],1,1) = 'c' 
                                    or substring(//marc:controlfield[@tag='006'],1,1) = 'm' 
                                    or substring(//marc:controlfield[@tag='006'],1,1) = 'p' 
                                    or substring(//marc:controlfield[@tag='006'],1,1) = 's'">
                        <xsl:if test="substring(//marc:controlfield[@tag='006'],7,1) = 'a' or substring(//marc:controlfield[@tag='006'],7,1) = 'b'">
                            <rdf:type rdf:resource="http://rdvocab.info/termList/RDAMediaType/1002" />
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
                    
                <!-- Thesis - This must be before AudioDocument, because otherwise it would be recognized as such-->
                <xsl:choose>
                    <xsl:when test="substring(.,7,1) = 'a' and contains(substring(//marc:controlfield[@tag='008'],25,4),'m')">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Thesis" />
                    </xsl:when>
                    <xsl:when test="substring(.,7,1) = 't' and contains(substring(//marc:controlfield[@tag='008'],25,4),'m')">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Thesis" />
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='006'],1,1) = 'a' and contains(substring(//marc:controlfield[@tag='006'],8,4),'m')">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Thesis" />
                    </xsl:when>
                </xsl:choose>
                    
                <!-- Proceedings -->
                <xsl:choose>
                    <xsl:when test="substring(.,7,1) = 'a' and substring(//marc:controlfield[@tag='008'],30,1) = '1'">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Proceedings" />
                    </xsl:when>
                    <xsl:when test="substring(.,7,1) = 't' and substring(//marc:controlfield[@tag='008'],30,1) = '1'">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Proceedings" />
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='006'],1,1) = 'a' and contains(substring(//marc:controlfield[@tag='006'],13,1),'1')">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Proceedings" />
                    </xsl:when>
                </xsl:choose>
                    
                <!-- Notated music -->
                <xsl:choose>
                    <xsl:when test="substring(.,7,1) = 'c' and substring(//marc:controlfield[@tag='008'],24,1) = 'r'">
                        <rdf:type rdf:resource="http://rdvocab.info/termList/RDAContentType/1010" /> 
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='006'],1,1) = 'c' and substring(//marc:controlfield[@tag='006'],7,1) = 'r'">
                        <rdf:type rdf:resource="http://rdvocab.info/termList/RDAContentType/1010" />
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='007'],1,1) = 'q'">
                        <rdf:type rdf:resource="http://rdvocab.info/termList/RDAContentType/1010" />
                    </xsl:when>
                </xsl:choose>
                    
                <!-- Map -->
                <xsl:choose>
                    <xsl:when test="substring(.,7,1) = 'e' or substring(//marc:controlfield[@tag='006'],1,1) = 'f' or substring(//marc:controlfield[@tag='007'],1,1) = 'a'">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Map" />
                    </xsl:when>
                </xsl:choose>
                    
                <!-- Report -->
                <xsl:choose>
                    <xsl:when test="substring(.,7,1) = 'a' and contains(substring(//marc:controlfield[@tag='008'],25,3),'t')">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Report" />
                    </xsl:when>
                    <xsl:when test="substring(.,7,1) = 't' and contains(substring(//marc:controlfield[@tag='008'],25,3),'t')">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Report" />
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='006'],1,1) = 'a' and contains(substring(//marc:controlfield[@tag='006'],8,4),'t')">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Report" />
                    </xsl:when>
                </xsl:choose>
                    
                <!-- AudioVisual Media -->
                <xsl:choose>
                    <xsl:when test="substring(.,7,1) = 'g' or substring(//marc:controlfield[@tag='007'],1,1) = 'm' or substring(//marc:controlfield[@tag='007'],1,1) = 'v'">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/AudioVisualDocument" />
                    </xsl:when>
                </xsl:choose>
                    
                <!-- AudioDocument -->
                <xsl:choose>
                    <xsl:when test="substring(.,7,1) = 'i' or substring(.,7,1) = 'j' or substring(//marc:controlfield[@tag='006'],1,1) = 'i' or substring(//marc:controlfield[@tag='006'],1,1) = 'j' or substring(//marc:controlfield[@tag='007'],1,1) = 's'">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/AudioDocument" />
                    </xsl:when>
                </xsl:choose>
                    
                <!-- Image -->
                <xsl:choose>
                    <xsl:when test="substring(.,7,1) = 'k' or substring(//marc:controlfield[@tag='006'],1,1) = 'k'">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Image" />
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='007'],1,1) = 'k' or substring(//marc:controlfield[@tag='007'],1,1) = 'r'">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Image" />
                    </xsl:when>
                </xsl:choose>
                         
                <!-- Printed work - This should only match in rare cases -->
                <xsl:choose>
                    <xsl:when test="substring(.,7,1) = 'a' and substring(//marc:controlfield[@tag='007'],2,1) = 't' and substring(//marc:controlfield[@tag='008'],24,1) = 'r'">
                        <rdf:type rdf:resource="http://purl.org/dc/dcmitype/Text" /> 
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='007'],1,1) = 't' and substring(//marc:controlfield[@tag='007'],2,1) != 'a'">
                        <rdf:type rdf:resource="http://purl.org/dc/dcmitype/Text" />
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='006'],1,1) = 'a' 
                                    or substring(//marc:controlfield[@tag='006'],1,1) = 'c' 
                                    or substring(//marc:controlfield[@tag='006'],1,1) = 'm' 
                                    or substring(//marc:controlfield[@tag='006'],1,1) = 'p' 
                                    or substring(//marc:controlfield[@tag='006'],1,1) = 's'">
                        <xsl:if test="substring(//marc:controlfield[@tag='006'],7,1) = 'r'">
                            <rdf:type rdf:resource="http://purl.org/dc/dcmitype/Text" />
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
                
                <!-- Website -->
                <xsl:choose>
                    <xsl:when test="substring(.,7,1) = 'm' and (substring(//marc:controlfield[@tag='007'],1,1)) = 'c'">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Website" />
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='006'],1,1) = 'e' or substring(//marc:controlfield[@tag='006'],1,1) = 'r'">
                        <xsl:if test="substring(//marc:controlfield[@tag='006'],7,1) = 'o'">
                            <rdf:type rdf:resource="http://purl.org/ontology/bibo/Website" />
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='007'],1,1) = 'c' and substring(//marc:controlfield[@tag='007'],2,1) = 'r'">
                        <rdf:type rdf:resource="http://purl.org/ontology/bibo/Website" />
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='006'],1,1) = 'a' 
                                    or substring(//marc:controlfield[@tag='006'],1,1) = 'c' 
                                    or substring(//marc:controlfield[@tag='006'],1,1) = 'm' 
                                    or substring(//marc:controlfield[@tag='006'],1,1) = 'p' 
                                    or substring(//marc:controlfield[@tag='006'],1,1) = 's'">
                        <xsl:if test="substring(//marc:controlfield[@tag='006'],7,1) = 'o'">
                            <rdf:type rdf:resource="http://purl.org/ontology/bibo/Website" />
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>

                <!-- Software -->
                <xsl:choose>
                    <xsl:when test="substring(.,7,1) = 'm' and substring(//marc:controlfield[@tag='007'],1,1) != 'c'">
                        <rdf:type rdf:resource="http://purl.org/dc/dcmitype/Software" />
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='006'],1,1) = 'e' or substring(//marc:controlfield[@tag='006'],1,1) = 'r'">
                        <xsl:if test="substring(//marc:controlfield[@tag='006'],7,1) = 'o' 
                                   or substring(//marc:controlfield[@tag='006'],7,1) = 'q' 
                                   or substring(//marc:controlfield[@tag='006'],7,1) = 's'">
                            <rdf:type rdf:resource="http://purl.org/dc/dcmitype/Software" />
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='006'],1,1) = 'a' 
                                    or substring(//marc:controlfield[@tag='006'],1,1) = 'c' 
                                    or substring(//marc:controlfield[@tag='006'],1,1) = 'm' 
                                    or substring(//marc:controlfield[@tag='006'],1,1) = 'p' 
                                    or substring(//marc:controlfield[@tag='006'],1,1) = 's'">
                        <xsl:if test="substring(//marc:controlfield[@tag='006'],7,1) = 'o' 
                                   or substring(//marc:controlfield[@tag='006'],7,1) = 'q' 
                                   or substring(//marc:controlfield[@tag='006'],7,1) = 's'">
                            <rdf:type rdf:resource="http://purl.org/dc/dcmitype/Software" />
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="substring(//marc:controlfield[@tag='007'],1,1) = 'c' and substring(//marc:controlfield[@tag='007'],2,1) != 'r'">
                        <rdf:type rdf:resource="http://purl.org/dc/dcmitype/Software" />
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            
            <!-- Title data -->
            
            <!-- Identifier -->
            <xsl:for-each select="//marc:datafield[@tag='035']/marc:subfield[@code='a']">
                <xsl:param name="EkiWithoutPrefix">
                    <xsl:value-of select="ext:deleteFromString(.,'\([^\)]+\)')" />
                </xsl:param>
                <xsl:choose>
                    <!-- Beware: Here the mappings to culturegraph.org are coded 3 times here (cases No. 2-4) -->
                    <xsl:when test="contains(.,'(OCoLC)')">
                        <foaf:homepage rdf:resource="{concat('http://worldcat.org/oclc/',ext:deleteFromString(.,'\(OCoLC\)'))}" />
                    </xsl:when>
                    <xsl:when test="contains(.,'(DE-101)DNB')">
                        <owl:sameAs rdf:resource="{concat('http://d-nb.info/',ext:deleteFromString(.,'\(DE-101\)DNB'))}" />
                        <owl:sameAs rdf:resource="{concat('http://www.culturegraph.org/about/',concat(substring($EkiWithoutPrefix,0,4),concat('-',substring($EkiWithoutPrefix,4))))}" />
                    </xsl:when>
                    <xsl:when test="contains(.,'(DE-600)ZDB')">
                        <!-- For ZDB, the BVB-Id is used for linking to culturegraph because the ZDB-Id does not work 
                             Example: http://www.culturegraph.org/about/ZDB-ZDB201077-x (404), 
                                      http://www.culturegraph.org/about/BVB-BV002578212 (200)
                        -->
                        <owl:sameAs rdf:resource="{concat('http://www.culturegraph.org/about/',concat('BVB',concat('-',$docId)))}" />
                        <owl:sameAs rdf:resource="{concat('http://ld.zdb-services.de/resource/',ext:deleteFromString(., '\(DE-600\)ZDB'))}" />
                    </xsl:when>
                    <xsl:when test="starts-with(.,'(DE-')">
                        <xsl:param name="EkiWithoutPrefix">
                            <xsl:value-of select="ext:deleteFromString(.,'\([^\)]+\)')" />
                        </xsl:param>
                        <!--(BSZ|BVB|DNB|GBV|HBZ|HEB|KBV|OBV|ZDB)[A-Z0-9]+$ -->
                        <xsl:if test="starts-with($EkiWithoutPrefix, 'BSZ') 
                                or starts-with($EkiWithoutPrefix, 'BVB') 
                                or starts-with($EkiWithoutPrefix, 'DNB')
                                or starts-with($EkiWithoutPrefix, 'GBV')
                                or starts-with($EkiWithoutPrefix, 'HBZ')
                                or starts-with($EkiWithoutPrefix, 'HEB')
                                or starts-with($EkiWithoutPrefix, 'KBV')
                                or starts-with($EkiWithoutPrefix, 'OBV')
                                or starts-with($EkiWithoutPrefix, 'ZDB')
                                ">
                            <owl:sameAs rdf:resource="{concat('http://www.culturegraph.org/about/',concat(substring($EkiWithoutPrefix,0,4),concat('-',substring($EkiWithoutPrefix,4))))}" />
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <dct:identifier>
                            <xsl:value-of select="."/>
                        </dct:identifier>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="starts-with($EkiWithoutPrefix, 'HBZ')">
                    <owl:sameAs rdf:resource="{concat('http://lobid.org/resource/',concat(ext:deleteFromString($EkiWithoutPrefix,'HBZ'),'/about'))}" />                       
                </xsl:if>
            </xsl:for-each>
            <xsl:for-each select="//marc:datafield[@tag='024']/marc:subfield[@code='a']/text()">
                <xsl:if test="starts-with(.,'VD17') or starts-with(.,'VD16')">
                    <foaf:homepage rdf:resource="{concat('http://gateway-bayern.de/',translate(.,' ','+'))}" />
                </xsl:if>
                <dct:identifier>
                    <xsl:value-of select="." />
                </dct:identifier>  
            </xsl:for-each>

            <!-- Title -->
            <xsl:for-each select="//marc:datafield[@tag='245']/marc:subfield[@code='a']">
                <dct:title>
                    <xsl:value-of select="normalize-space(ext:deleteFromString(./text(),'/$|:$'))"/>                    
                    <xsl:if test="../marc:subfield[@code='t']/text()">
                        <xsl:value-of select="concat(' ',normalize-space(translate(../marc:subfield[@code='t']/text(),'/','')))" />
                    </xsl:if>
                    <xsl:if test="../marc:subfield[@code='n']/text()">
                        <xsl:value-of select="concat('. ',normalize-space(translate(../marc:subfield[@code='n']/text(),'/,','')))" />
                    </xsl:if>
                    <xsl:if test="../marc:subfield[@code='p']/text()">
                        <xsl:value-of select="concat(': ',normalize-space(translate(../marc:subfield[@code='p']/text(),'/,:','')))" />
                    </xsl:if>
                    <!--xsl:if test="../marc:subfield[@code='t']/text()">
                        <xsl:value-of select="concat(' ',normalize-space(translate(../marc:subfield[@code='t']/text(),'/','')))" />
                    </xsl:if-->
                </dct:title>
            </xsl:for-each>
            
            <!-- Subtitle -->
            <xsl:for-each select="//marc:datafield[@tag='245']/marc:subfield[@code='b']">
                <isbd:P1006>
                    <xsl:value-of select="normalize-space(ext:deleteFromString(./text(),'/$'))" />
                </isbd:P1006>
            </xsl:for-each>
            <xsl:for-each select="//marc:datafield[@tag='246']/marc:subfield[@code='a']">
                <dct:alternative> 
                    <xsl:value-of select="." />
                </dct:alternative>
            </xsl:for-each>
            
            <!-- 
            Volume (iterate over all volume numbers: 773$g, 810$v, 830$v)
            Important: If you change something here, remember to change the 'Some links from Collections to their items' part above! 
                       Otherwise, the generated URIs will be inconsistent.
            -->
            <xsl:for-each select="//marc:datafield[@tag='773']/marc:subfield[@code='g']/text()|
                                  //marc:datafield[@tag='830']/marc:subfield[@code='v']/text()|
                                  //marc:datafield[@tag='810']/marc:subfield[@code='v']/text()">  
                <xsl:param name="seriesId">
                    <xsl:value-of select="ext:deleteFromString(../../marc:subfield[@code='w'],'\([^\)]+\)')" />
                </xsl:param>
                <!-- in 773, volume numbers are in $g, in 810 & 830 in $v-->
                <xsl:param name="volumeNumber773">
                    <xsl:value-of select="ext:deleteFromString(../../marc:subfield[@code='g'],'\D')" />
                </xsl:param>
                <xsl:param name="volumeNumber8x0">
                    <xsl:value-of select="ext:deleteFromString(../../marc:subfield[@code='v'],'\D')" />
                </xsl:param>
                <xsl:choose>
                    <xsl:when test="string-length($seriesId) &gt; 0 and 
                                    (string-length($volumeNumber773) &gt; 0 or string-length($volumeNumber8x0) &gt; 0)">
                        <xsl:choose>
                            <xsl:when test="string-length($volumeNumber773) &gt; 0">
                                <owl:sameAs rdf:resource="{concat($docIdUriPrefix,$seriesId)}/vol/{$volumeNumber773}"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <owl:sameAs rdf:resource="{concat($docIdUriPrefix,$seriesId)}/vol/{$volumeNumber8x0}"/>
                            </xsl:otherwise>
                        </xsl:choose>                  
                    </xsl:when>
                    <!-- if there is no series Id to link to, just insert a simple bibo:volume -->
                    <xsl:otherwise>
                        <bibo:volume>
                            <xsl:value-of select="." />
                        </bibo:volume>
                    </xsl:otherwise>
                </xsl:choose>   
            </xsl:for-each>
            
            <!-- Link up -->
            <xsl:for-each select="//marc:datafield[@tag='773']/marc:subfield[@code='w']/text()|//marc:datafield[@tag='830']/marc:subfield[@code='w']/text()|//marc:datafield[@tag='810']/marc:subfield[@code='w']/text()">
                <dct:isPartOf rdf:resource="{concat($docIdUriPrefix,ext:deleteFromString(.,'\([^\)]+\)'))}" />
            </xsl:for-each>
            
            <!-- Authors / Creators -->
            <xsl:for-each select="//marc:datafield[@tag='100']/marc:subfield[@code='0']/text()">
                <dct:creator rdf:resource="{concat($gndUriPrefix, ext:getGndNumber(.))}" />
                <!-- Write Marc Relator Code Triples -->
                <xsl:if test="../../marc:subfield[@code='4']/text()">
                    <xsl:value-of select="ext:getMarcRelatorTriple($gndUriPrefix,.,../../marc:subfield[@code='4']/text())" disable-output-escaping="yes"/>
                </xsl:if>
            </xsl:for-each>
            
            <!-- Contributors -->
            <xsl:for-each select="//marc:datafield[@tag='700']/marc:subfield[@code='0']/text()">
                <xsl:param name="contributorUri">
                    <xsl:value-of select="concat($gndUriPrefix, ext:getGndNumber(.))" />
                </xsl:param>
                <xsl:choose>
                    <xsl:when test="../../marc:subfield[@code='e']/text() != 'Hrsg.'">
                        <dct:contributor rdf:resource="{$contributorUri}" />
                        <!-- Write Marc Relator Code Triples -->
                        <xsl:if test="../../marc:subfield[@code='4']/text()">
                            <xsl:value-of select="ext:getMarcRelatorTriple($gndUriPrefix,.,../../marc:subfield[@code='4']/text())" disable-output-escaping="yes"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <bibo:editor rdf:resource="{$contributorUri}" />
                        <xsl:if test="../../marc:subfield[@code='4']/text()">
                            <!-- Write Marc Relator Code Triples -->
                            <xsl:value-of select="ext:getMarcRelatorTriple($gndUriPrefix,.,../../marc:subfield[@code='4']/text())" disable-output-escaping="yes"/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <!-- Schlagworte (SWD, LCSH) -->
            <xsl:for-each select="//marc:datafield[@tag='600']|//marc:datafield[@tag='610']|//marc:datafield[@tag='611']|//marc:datafield[@tag='630']|//marc:datafield[@tag='648']|//marc:datafield[@tag='650']|//marc:datafield[@tag='651']|//marc:datafield[@tag='652']|//marc:datafield[@tag='653']|//marc:datafield[@tag='654']|//marc:datafield[@tag='656']|//marc:datafield[@tag='657']|//marc:datafield[@tag='658']|//marc:datafield[@tag='659']|//marc:datafield[@tag='689']">
                <xsl:choose>
                    <!-- GND-Numbers are transformed to GND-URIs -->
                    <xsl:when test="starts-with(./marc:subfield[@code='0']/text(),'(DE-588)')">
                        <dct:subject rdf:resource="{concat($gndUriPrefix, ext:getGndNumber(./marc:subfield[@code='0']/text()))}" />
                    </xsl:when>
                    <!-- If no number available, print the subject heading into a String-literal -->
                    <xsl:when test="./marc:subfield[@code='a']/text() and ./marc:subfield[@code='2']/text() = 'gnd'">
                        <dc:subject>
                            <xsl:value-of select="normalize-space(translate(./marc:subfield[@code='a']/text(),'.',''))"/>
                        </dc:subject>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Check if the preferredLabel can be mapped to a LCSH URI-->
                        <xsl:param name="subjectAnsF">
                            <xsl:value-of select="translate(./marc:subfield[@code='a']/text(),'.','')"/>
                        </xsl:param>
                        <xsl:param name="lcshUri">
                            <xsl:if test="@tag='650'">
                                <xsl:value-of select="ext:retrieveLcshUri($sparqlEndpointLCSH, $subjectAnsF)" />
                            </xsl:if>
                        </xsl:param>                   
                        <xsl:choose>
                            <xsl:when test="$lcshUri">                     
                                <dct:subject rdf:resource="{$lcshUri}" />
                            </xsl:when>
                            <!-- If no LCSH-URI can be matched (or the preferredLabel is ambiguous) just write a dc:subject with the plain text-->
                            <xsl:when test="string-length($subjectAnsF) &gt; 0">
                                <dc:subject>
                                    <xsl:value-of select="normalize-space($subjectAnsF)" />
                                </dc:subject>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            <!-- Klassifikationen (RVK, DDC, SSG-Nummer) -->
            <!-- ToDo: Die URIs für rvk & ssg sind fiktiv -> Wann gibt es das als LOD? -->
            <xsl:for-each select="//marc:datafield[@tag='082']/marc:subfield[@code='a']/text()|//marc:datafield[@tag='089']/marc:subfield[@code='c']/text()">
                <!-- Sometimes input DDCs look like this: 920/.043 B 19. In this case, we replace the / and everything following the space-->
                <xsl:param name="cleanDdc">
                    <xsl:value-of select="ext:deleteFromString(translate(.,'/',''),'\s.+$')" />
                </xsl:param>
                <xsl:choose>
                    <xsl:when test="ext:matches($cleanDdc,'^\d{3}(\.\d{1,4})*$')">
                        <dct:subject rdf:resource="{concat(concat('http://dewey.info/class/',$cleanDdc),'/about')}" />
                    </xsl:when>
                    <xsl:otherwise>
                        <dct:subject rdf:resource="{concat(concat('http://dewey.info/class/',substring($cleanDdc,0,6)),'/about')}" />
                    </xsl:otherwise>
                </xsl:choose>
                <!-- Additional output of DDCs as literal because some users prefer that to dewey.info-URIs 
                    (and those are sometimes not possible; e.g. synthetic notations)
                    Fortunately, there is a datatype for those: dct:ddc
                -->
                <dc:subject rdf:datatype="http://purl.org/dc/terms/DDC">
                    <xsl:value-of select="translate(.,'/','')"/>
                </dc:subject>
            </xsl:for-each>
            <xsl:for-each select="//marc:datafield[@tag='084']/marc:subfield[@code='a']/text()">
                <xsl:choose>
                    <xsl:when test="../../marc:subfield[@code='2']/text() = 'ssgn'">
                        <dct:subject rdf:resource="{concat($ssgUriPrefix,translate(.,',','.'))}" />
                    </xsl:when>
                    <xsl:when test="../../marc:subfield[@code='2']/text() = 'rvk'">
                        <dct:subject rdf:resource="{concat($rvkUriPrefix,translate(.,' ',''))}" />
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            <!-- SWD-Formschlagworte -->
            <xsl:for-each select="//marc:datafield[@tag='655']">
                <dc:subject xml:lang="de">
                    <xsl:value-of select="normalize-space(translate(./marc:subfield[@code='a']/text(),'.',''))" />
                </dc:subject>
            </xsl:for-each>
            
            <!-- ISBN / ISSN -->
            <xsl:for-each select="//marc:datafield[@tag='020']/marc:subfield[@code='a']/text()">
                <bibo:isbn>
                    <xsl:value-of select="ext:deleteFromString(.,'-')" />
                </bibo:isbn>
            </xsl:for-each>
            <xsl:for-each select="//marc:datafield[@tag='022']/marc:subfield[@code='a']/text()|//marc:datafield[@tag='022']/marc:subfield[@code='y']">
                <xsl:if test="not(contains(.,'ZBTBA'))">
                    <bibo:issn>
                        <xsl:value-of select="." />
                    </bibo:issn>
                </xsl:if>
            </xsl:for-each>
            
            <!-- Extent -->
            <xsl:for-each select="//marc:datafield[@tag='300']">
                <xsl:param name="rawExtent">
                    <xsl:for-each select="./marc:subfield">
                        <xsl:value-of select="concat(normalize-space(translate(.,';:','')),' ')" />
                    </xsl:for-each>
                </xsl:param>
                <dct:extent>
                    <xsl:value-of select="normalize-space($rawExtent)" />
                </dct:extent>
            </xsl:for-each>
                
            <!-- Language Code -->
            <xsl:param name="lang008">
                <xsl:value-of select="substring(//marc:controlfield[@tag='008']/text(),36,3)"/>
            </xsl:param>
            <xsl:if test="$lang008">
                <xsl:param name="langUri008">
                    <xsl:value-of select="concat('http://id.loc.gov/vocabulary/iso639-2/',$lang008)" />
                </xsl:param>
                <dct:language rdf:resource="{$langUri008}"/>
            </xsl:if>
            <xsl:for-each select="//marc:datafield[@tag='041']/marc:subfield[@code='a']/text()|//marc:datafield[@tag='041']/marc:subfield[@code='h']/text()">
                <xsl:if test="$lang008 != .">
                    <xsl:param name="langUri41">
                        <xsl:value-of select="concat('http://id.loc.gov/vocabulary/iso639-2/',.)" />
                    </xsl:param>
                    <dct:language rdf:resource="{$langUri41}" />
                </xsl:if>
            </xsl:for-each>

            <!-- Publication event -->
            <xsl:for-each select="//marc:datafield[@tag='260']">
                <xsl:param name="pubPlace">
                    <xsl:value-of select="normalize-space(translate(./marc:subfield[@code='a']/text(),':,',''))" />
                </xsl:param>
                <xsl:param name="pubPublisher">
                    <xsl:value-of select="normalize-space(translate(./marc:subfield[@code='b']/text(),',',''))" />
                </xsl:param>
                <xsl:param name="pubYear">
                    <xsl:value-of select="./marc:subfield[@code='c']/text()" />
                </xsl:param>
                <xsl:param name="pubYearInt1">
                    <xsl:value-of select="translate(substring(//marc:controlfield[@tag='008'],8,4), 'äu','')" />
                </xsl:param>
                <xsl:param name="pubYearInt2">
                    <xsl:value-of select="translate(substring(//marc:controlfield[@tag='008'],12,4), 'äu','')" />
                </xsl:param>
                <xsl:if test="$pubPlace">
                    <isbd:P1016>
                        <xsl:value-of select="$pubPlace" />
                    </isbd:P1016>
                    <xsl:param name="marcCountryCode">
                        <xsl:value-of select="translate(substring(//marc:controlfield[@tag='008'],16,3), 'ä','')"/>
                    </xsl:param>
                    <xsl:param name="isoCountryCode">
                        <xsl:value-of select="substring(//marc:datafield[@tag='044']/marc:subfield[@code='c']/text(),4,2)"/>
                    </xsl:param>
                    <xsl:if test="string-length($marcCountryCode) > 1">
                        <rdagr1:placeOfPublication rdf:resource="{concat('http://id.loc.gov/vocabulary/countries/',translate(substring(//marc:controlfield[@tag='008'],16,3),'ä',''))}" />
                    </xsl:if>
                    <xsl:if test="$isoCountryCode">
                        <geonames:countryCode>
                            <xsl:value-of select="$isoCountryCode"/>
                        </geonames:countryCode>
                    </xsl:if>
                </xsl:if>
                <xsl:if test="$pubPublisher">
                    <dct:publisher>
                        <xsl:value-of select="normalize-space(translate($pubPublisher,';',''))" />
                    </dct:publisher>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="$pubYearInt1">
                        <dct:issued rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
                            <xsl:value-of select="$pubYearInt1" />
                        </dct:issued>
                    </xsl:when>
                    <xsl:when test="$pubYear">
                        <dct:issued>
                            <xsl:value-of select="$pubYear" />
                        </dct:issued>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="$pubYearInt2 and $pubYearInt2 != '9999'">
                    <dct:issued rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
                        <xsl:value-of select="$pubYearInt2" />
                    </dct:issued>
                </xsl:if>
            </xsl:for-each>

            <!-- Link to frbr:Items (frbr:exemplar) -->
            <xsl:for-each select="//marc:datafield[@tag='049']/marc:subfield[@code='a']/text()">
                <xsl:if test="not(. = 'HVR01' or . = 'LGW01' or . = 'OGB01' or . = 'VAN01' or . = 'VGA01' or . = 'VGB01' or . = 'VGH01' or . = 'VGM01' or . = 'VGR01' or . = 'VGW01')">
                    <xsl:param name="isilExLink">
                        <xsl:value-of select="ext:getIsilFor($sparqlEndpointBibData,.)" />
                    </xsl:param>
                    <xsl:param name="exemplarUriExLink">
                        <!-- TODO -->
                        <xsl:value-of select="concat(concat($bibUriPrefix,concat(concat($isilExLink,'/'),'item/'),$docId),'')" />
                    </xsl:param>
                    <frbr:exemplar rdf:resource="{$exemplarUriExLink}" />
                </xsl:if>
            </xsl:for-each>
            
            <!-- MARC general notes as dc:descriptions -->
            <xsl:for-each select="//marc:datafield[@tag='500']/marc:subfield[@code='a']|//marc:datafield[@tag='245']/marc:subfield[@code='c']">
                <dct:description>
                    <xsl:value-of select="normalize-space(translate(./text(),'/.',''))" />
                </dct:description>
            </xsl:for-each>
            
            <!-- 505 as TableOfContents -->
            <xsl:for-each select="//marc:datafield[@tag='505']/marc:subfield[@code='a']/text()">
                <dct:tableOfContents>
                    <xsl:value-of select="." />
                </dct:tableOfContents>
            </xsl:for-each>
            
            <!-- Weblinks -->
            <xsl:for-each select="//marc:datafield[@tag='856']/marc:subfield[@code='3']">
                <!-- Filter out any URLs except for fulltext-URLs -->
                <xsl:if test="contains(., 'Volltext')">
                    <foaf:homepage rdf:resource="{../marc:subfield[@code='u']}" />
                </xsl:if>
            </xsl:for-each>
            

            <!-- End of Title Data -->

            <xsl:apply-templates/>
        
        </rdf:Description>
        
        <!-- 
            Some links from Collections to their items 
            Important: If you change something here, remember to change the 'Volume' part above! 
                       Otherwise, the generated URIs will be inconsistent. 
        -->
        <xsl:for-each select="//marc:datafield[@tag='773']/marc:subfield[@code='g']/text()|
                                  //marc:datafield[@tag='830']/marc:subfield[@code='v']/text()|
                                  //marc:datafield[@tag='810']/marc:subfield[@code='v']/text()"> 
            <xsl:param name="seriesIdVolumeUri">
                <xsl:value-of select="ext:deleteFromString(../../marc:subfield[@code='w'],'\([^\)]+\)')" />
            </xsl:param>
            <!-- in 773, volume numbers are in $g, in 810 & 830 in $v-->
            <xsl:param name="volumeNumber773VolumeUri">
                <xsl:value-of select="ext:deleteFromString(../../marc:subfield[@code='g'],'\D')" />
            </xsl:param>
            <xsl:param name="volumeNumber8x0VolumeUri">
                <xsl:value-of select="ext:deleteFromString(../../marc:subfield[@code='v'],'\D')" />
            </xsl:param>     
            <xsl:choose>
                <xsl:when test="string-length($seriesIdVolumeUri) &gt; 0 and 
                                    (string-length($volumeNumber773VolumeUri) &gt; 0 or string-length($volumeNumber8x0VolumeUri) &gt; 0)">
                    <rdf:Description rdf:about="{concat($docIdUriPrefix,$seriesIdVolumeUri)}">
                        <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Document" />
                        <xsl:choose>
                            <xsl:when test="string-length($volumeNumber773VolumeUri) &gt; 0">
                                <dct:hasPart rdf:resource="{concat($docIdUriPrefix,$seriesIdVolumeUri)}/vol/{$volumeNumber773VolumeUri}" />
                            </xsl:when>
                            <xsl:otherwise>
                                <dct:hasPart rdf:resource="{concat($docIdUriPrefix,$seriesIdVolumeUri)}/vol/{$volumeNumber8x0VolumeUri}" /> 
                            </xsl:otherwise>
                        </xsl:choose>
                    </rdf:Description>
                    <!-- Volume-URIs -->
                    <xsl:choose>
                        <xsl:when test="string-length($volumeNumber773VolumeUri) &gt; 0">
                            <rdf:Description rdf:about="{concat($docIdUriPrefix,$seriesIdVolumeUri)}/vol/{$volumeNumber773VolumeUri}">
                                <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Document" />
                                <bibo:volume>
                                    <xsl:value-of select="." />
                                </bibo:volume>
                                <owl:sameAs rdf:resource="{$titleUri}"/>
                            </rdf:Description>
                        </xsl:when>
                        <xsl:otherwise>
                            <rdf:Description rdf:about="{concat($docIdUriPrefix,$seriesIdVolumeUri)}/vol/{$volumeNumber8x0VolumeUri}">
                                <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Document" />
                                <bibo:volume>
                                    <xsl:value-of select="." />
                                </bibo:volume>
                                <owl:sameAs rdf:resource="{$titleUri}"/>
                            </rdf:Description>
                        </xsl:otherwise>
                    </xsl:choose>      
                </xsl:when>
                <!-- if there was no volume number just write a simple link between the two title-URIs -->
                <xsl:when test="string-length($seriesIdVolumeUri) &gt; 0">
                    <rdf:Description rdf:about="{concat($docIdUriPrefix,$seriesIdVolumeUri)}">
                        <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Document" />
                        <dct:hasPart rdf:resource="{$titleUri}" />
                    </rdf:Description> 
                </xsl:when>
            </xsl:choose>
                       
        </xsl:for-each>
            
        <!-- Description of temporary SSGs and RVKs -->
        <xsl:for-each select="//marc:datafield[@tag='084']/marc:subfield[@code='a']/text()">
            <xsl:choose>
                <xsl:when test="../../marc:subfield[@code='2']/text() = 'ssgn'">
                    <skos:Concept rdf:about="{concat($ssgUriPrefix,translate(.,',','.'))}">
                        <foaf:homepage rdf:resource="{concat('http://webis.sub.uni-hamburg.de/webis/index.php/',translate(.,',','.'))}" />
                    </skos:Concept>
                </xsl:when>
                <xsl:when test="../../marc:subfield[@code='2']/text() = 'rvk'">
                    <skos:Concept rdf:about="{concat($rvkUriPrefix,translate(.,' ',''))}">
                        <foaf:homepage rdf:resource="http://rvk.uni-regensburg.de/" />
                    </skos:Concept>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
            
        <!-- Holdings: frbr:Items-->
        <xsl:for-each select="//marc:datafield[@tag='049']/marc:subfield[@code='a']/text()">
            <xsl:param name="currentBibId">
                <xsl:value-of select="//marc:datafield[@tag='049']/marc:subfield[@code='a']/text()" />
            </xsl:param>
            <xsl:if test="not(. = 'HVR01' or . = 'LGW01' or . = 'OGB01' or . = 'VAN01' or . = 'VGA01' or . = 'VGB01' or . = 'VGH01' or . = 'VGM01' or . = 'VGR01' or . = 'VGW01')">
                <xsl:param name="isil">
                    <xsl:value-of select="ext:getIsilFor($sparqlEndpointBibData,.)" />
                </xsl:param>
                <xsl:param name="bibUri">
                    <xsl:value-of select="concat($bibUriPrefix,$isil)" />
                </xsl:param>
                <xsl:param name="exemplarUri">
                    <!-- TODO -->
                    <xsl:value-of select="concat(concat($bibUriPrefix,concat(concat($isil,'/'),'item/'),$docId),'')" />
                </xsl:param>
                <frbr:Item rdf:about="{$exemplarUri}">
                    <xsl:choose>
                        <xsl:when test="$bibUri">
                            <xsl:param name="bibNameExemplar">
                                <xsl:value-of select="ext:getBibNameFor($sparqlEndpointBibData,$bibUri)" />
                            </xsl:param>
                            <xsl:choose>
                                <xsl:when test="$bibNameExemplar">
                                    <rdfs:label xml:lang="de">
                                        <xsl:text>Besitznachweis: </xsl:text>
                                        <xsl:value-of select="$bibNameExemplar"/>
                                    </rdfs:label>
                                </xsl:when>
                                <xsl:otherwise>
                                    <rdfs:label xml:lang="de">
                                        <xsl:text>Besitznachweis</xsl:text>
                                    </rdfs:label>
                                </xsl:otherwise>
                            </xsl:choose>
                            <frbr:owner rdf:resource="{$bibUri}" />
                            <xsl:param name="opacLink">
                                <xsl:value-of select="ext:getOpacLinkFor($sparqlEndpointBibData, $bibUri, $docId)"/>
                            </xsl:param>
                            <xsl:if test = "$opacLink">
                                <foaf:homepage rdf:resource="{$opacLink}" />
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <rdfs:label xml:lang="de">
                                Besitznachweis
                            </rdfs:label>
                            <rdfs:label xml:lang="en">
                                Holding
                            </rdfs:label>
                            <frbr:owner>
                                <xsl:value-of select="$currentBibId" />
                            </frbr:owner>
                        </xsl:otherwise>
                    </xsl:choose>
                </frbr:Item>
            </xsl:if>
        </xsl:for-each>
        <!-- End of Holdings -->

        <!-- SameAs-Links that allow getting the Title by it's ISBN/ISSN -->   
        <xsl:for-each select="//marc:datafield[@tag='020']/marc:subfield[@code='a']/text()">
            <xsl:param name="isbn">
                <xsl:value-of select="." />
            </xsl:param>       
            <rdf:Description rdf:about="{concat($isbnUriPrefix,$isbn)}">
                <owl:sameAs rdf:resource="{concat($docIdUriPrefix,$docId)}" />
            </rdf:Description>
        </xsl:for-each>
        <xsl:for-each select="//marc:datafield[@tag='022']/marc:subfield[@code='a']/text()|//marc:datafield[@tag='022']/marc:subfield[@code='y']">
            <xsl:if test="not(contains(.,'ZBTBA'))">
                <xsl:param name="issn">
                    <xsl:value-of select="." />
                </xsl:param>
                <rdf:Description rdf:about="{concat($issnUriPrefix,$issn)}">
                    <owl:sameAs rdf:resource="{concat($docIdUriPrefix,$docId)}" />
                </rdf:Description>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="marc:leader">
    </xsl:template>

    <xsl:template match="marc:controlfield">
    </xsl:template>

    <xsl:template match="//marc:datafield">
    </xsl:template>
        
</xsl:stylesheet>