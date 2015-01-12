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
    xmlns:xalan="http://xml.apache.org/xalan"
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
    xmlns:marc="http://www.loc.gov/MARC21/slim"
    version="1.0"><!-- rdf rdfs owl dc dct dcmitype bibo marc frbr foaf skos geonames rdagr1 marcrel isbd"-->
    <!-- exclude-result-prefixes="xsl marc xalan rdf rdfs owl dc dct dcmitype bibo marc frbr foaf skos geonames rdagr1 marcrel isbd" -->
    <xsl:output method="xml" encoding="UTF-8" indent="yes" />

    <!-- General Settings -->
    <xsl:param name="uriPrefix">
        <xsl:text>https://katalog.ub.uni-leipzig.de/</xsl:text>
    </xsl:param>
    <xsl:param name="bibUriPrefix">
        <xsl:text>https://katalog.ub.uni-leipzig.de/</xsl:text>
    </xsl:param>
    <xsl:param name="docIdUriPrefix">
        <xsl:value-of select="concat($uriPrefix, 'Record/')" />
    </xsl:param>
    <xsl:param name="isbnUriPrefix">
        <xsl:value-of select="concat($uriPrefix, 'Search/Results?type=ISN&amp;lookfor=')" />
    </xsl:param>
    <xsl:param name="issnUriPrefix">
        <xsl:value-of select="concat($uriPrefix, 'issn/')" />
    </xsl:param>
    <xsl:param name="rvkUriPrefix">
        <xsl:value-of select="concat( $uriPrefix, 'Search/Results?type=rvk&amp;lookfor=&#34;**rvk**&#34;')" />
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
    <xsl:param name="contributorUri">
        <!-- <xsl:value-of select="concat($gndUriPrefix, ext:getGndNumber(.))" /> -->
    </xsl:param>
    <!-- Sometimes input DDCs look like this: 920/.043 B 19. In this case, we replace the / and everything following the space-->
    <!--    <xsl:param name="cleanDdc">
         TODO CHECK 
         <xsl:value-of select="ext:deleteFromString(translate(.,'/',''),'\s.+$')" /> 
        <xsl:value-of select="replace(translate(.,'/',''),'\s.+$','')" />
    </xsl:param>-->
    <!--    <xsl:param name="rawExtent">
        <xsl:for-each select="./marc:subfield">
            <xsl:value-of select="normalize-space(concat(normalize-space(translate(.,';:','')),' '))" />
        </xsl:for-each>
    </xsl:param>-->
    <!-- Language Code -->
    <xsl:param name="lang008">
        <xsl:value-of select="substring(//marc:controlfield[@tag='008']/text(),36,3)"/>
    </xsl:param>
    <xsl:param name="langUri008">
        <xsl:value-of select="concat('http://id.loc.gov/vocabulary/iso639-2/',$lang008)" />
    </xsl:param>
    <!--    <xsl:param name="pubPlace">
        <xsl:value-of select="normalize-space(translate(./marc:subfield[@code='a']/text(),':,',''))" />
    </xsl:param>-->
    <!--    <xsl:param name="pubPublisher">
        <xsl:value-of select="normalize-space(translate(./marc:subfield[@code='b']/text(),',',''))" />
    </xsl:param>-->
    <!--    <xsl:param name="pubYear">
        <xsl:value-of select="./marc:subfield[@code='c']/text()" />
    </xsl:param>-->
    <xsl:param name="pubYearInt1">
        <xsl:value-of select="translate(substring(//marc:controlfield[@tag='008'],8,4), 'äu','')" />
    </xsl:param>
    <xsl:param name="pubYearInt2">
        <xsl:value-of select="translate(substring(//marc:controlfield[@tag='008'],12,4), 'äu','')" />
    </xsl:param>
    <xsl:param name="marcCountryCode">
        <xsl:value-of select="translate(substring(//marc:controlfield[@tag='008'],16,3), 'ä','')"/>
    </xsl:param>
    <xsl:param name="isilExLink">
        <!-- TODO -->
        <!-- <xsl:value-of select="ext:getIsilFor($sparqlEndpointBibData,.)" /> -->
        <xsl:text>DE-15</xsl:text>
    </xsl:param>
    <xsl:param name="exemplarUriExLink">
        <!-- TODO -->
        <xsl:value-of select="concat(concat($bibUriPrefix,concat(concat($isilExLink,'/'),'item/'),$docId),'')" />
    </xsl:param>
    <!--    <xsl:param name="seriesIdVolumeUri">
         TODO CHECK 
         <xsl:value-of select="ext:deleteFromString(../../marc:subfield[@code='w'],'\([^\)]+\)')" /> 
        <xsl:value-of select="replace(../../marc:subfield[@code='w'],'\([^\)]+\)','')" />
    </xsl:param>-->
    <!-- in 773, volume numbers are in $g, in 810 & 830 in $v-->
    <!--    <xsl:param name="volumeNumber773VolumeUri">
         TODO CHECK 
         <xsl:value-of select="ext:deleteFromString(../../marc:subfield[@code='g'],'\D')" /> 
        <xsl:value-of select="replace(../../marc:subfield[@code='g'],'\D','')" />
    </xsl:param>-->
    <!--    <xsl:param name="volumeNumber8x0VolumeUri">
         TODO CHECK 
         <xsl:value-of select="ext:deleteFromString(../../marc:subfield[@code='v'],'\D')" /> 
        <xsl:value-of select="replace(../../marc:subfield[@code='v'],'\D','')" />
    </xsl:param>-->
    <xsl:param name="currentBibId">
        <xsl:value-of select="//marc:datafield[@tag='049']/marc:subfield[@code='a']/text()" />
    </xsl:param>
    <xsl:param name="isil">
        <!-- <xsl:value-of select="ext:getIsilFor($sparqlEndpointBibData,.)" /> -->
        <xsl:text>DE-15</xsl:text>
    </xsl:param>
    <xsl:param name="bibUri">
        <xsl:value-of select="concat($bibUriPrefix,$isil)" />
    </xsl:param>
    <xsl:param name="exemplarUri">
        <!-- TODO -->
        <xsl:value-of select="concat($bibUriPrefix,concat(concat($isil,'/'),'item/'),$docId)" />
    </xsl:param>
    <xsl:param name="bibNameExemplar">
        <!-- <xsl:value-of select="ext:getBibNameFor($sparqlEndpointBibData,$bibUri)" /> -->
    </xsl:param>
    <xsl:param name="opacLink">
        <xsl:value-of select="concat('https://katalog.ub.uni-leipzig.de/Record/', $docId)"/>
    </xsl:param>
    <xsl:param name="bszUriPrefix">
        <xsl:text>http://swb.bsz-bw.de/DB=2.1/PPNSET?REC=2&amp;PPN=</xsl:text>
    </xsl:param>

    <xsl:template match="/">
        <xsl:if test="string-length($docId) > 1">
            <xsl:call-template name="mainMapping"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="mainMapping">
        <rdf:RDF>
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
                    <xsl:choose>
                        <!-- Beware: Here the mappings to culturegraph.org are coded 3 times here (cases No. 2-4) -->
                        <xsl:when test="contains(.,'(OCoLC)')">
                            <!-- TODO CHECK -->
                            <!-- <foaf:homepage rdf:resource="{concat('http://worldcat.org/oclc/',ext:deleteFromString(.,'\(OCoLC\)'))}" /> -->
                            <foaf:homepage rdf:resource="{concat('http://worldcat.org/oclc/',replace(.,'\(OCoLC\)',''))}" />
                        </xsl:when>
                        <xsl:when test="contains(.,'(DE-101)DNB')">
                            <!-- TODO CHECK -->
                            <!-- <owl:sameAs rdf:resource="{concat('http://d-nb.info/',ext:deleteFromString(.,'\(DE-101\)DNB'))}" /> -->
                            <owl:sameAs rdf:resource="{concat('http://d-nb.info/',replace(.,'\(DE-101\)DNB',''),'/about')}" />
                            <owl:sameAs rdf:resource="{concat('http://hub.culturegraph.org/about/',concat(substring(replace(.,'\([^\)]+\)',''),0,4),concat('-',substring(replace(.,'\([^\)]+\)',''),4))))}" />
                        </xsl:when>
                        <xsl:when test="starts-with(./text(),'(DE-599)ZDB')">
                            <owl:sameAs rdf:resource="{concat('http://ld.zdb-services.de/data/', substring(./text(),12))}" />
                        </xsl:when>
                        <xsl:when test="contains(.,'(DE-600)ZDB')">
                            <!-- For ZDB, the BVB-Id is used for linking to culturegraph because the ZDB-Id does not work 
                                 Example: http://hub.culturegraph.org/about/ZDB-ZDB201077-x (404), 
                                          http://hub.culturegraph.org/about/BVB-BV002578212 (200)
                            -->
                            <owl:sameAs rdf:resource="{concat('http://hub.culturegraph.org/about/','BVB','-',$docId)}" />
                            <!-- TODO CHECK -->
                            <!-- <owl:sameAs rdf:resource="{concat('http://ld.zdb-services.de/resource/',ext:deleteFromString(., '\(DE-600\)ZDB'))}" /> -->
                            <owl:sameAs rdf:resource="{concat('http://ld.zdb-services.de/resource/',replace(., '\(DE-600\)ZDB',''))}" />
                        </xsl:when>
                        <xsl:when test="starts-with(.,'(DE-')">
                            <!--(BSZ|BVB|DNB|GBV|HBZ|HEB|KBV|OBV|ZDB)[A-Z0-9]+$ -->
                            <xsl:if test="starts-with(replace(.,'\([^\)]+\)',''), 'BSZ') 
                                or starts-with(replace(.,'\([^\)]+\)',''), 'BVB') 
                                or starts-with(replace(.,'\([^\)]+\)',''), 'DNB')
                                or starts-with(replace(.,'\([^\)]+\)',''), 'GBV')
                                or starts-with(replace(.,'\([^\)]+\)',''), 'HBZ')
                                or starts-with(replace(.,'\([^\)]+\)',''), 'HEB')
                                or starts-with(replace(.,'\([^\)]+\)',''), 'KBV')
                                or starts-with(replace(.,'\([^\)]+\)',''), 'OBV')
                                or starts-with(replace(.,'\([^\)]+\)',''), 'ZDB')
                                ">
                                <owl:sameAs rdf:resource="{concat('http://hub.culturegraph.org/about/',concat(substring(replace(.,'\([^\)]+\)',''),0,4),concat('-',substring(replace(.,'\([^\)]+\)',''),4))))}" />
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <dct:identifier>
                                <xsl:value-of select="."/>
                            </dct:identifier>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="starts-with(replace(.,'\([^\)]+\)',''), 'HBZ')">
                        <!-- TODO CHECK -->
                        <!-- <owl:sameAs rdf:resource="{concat('http://lobid.org/resource/',concat(ext:deleteFromString($EkiWithoutPrefix,'HBZ'),'/about'))}" /> -->
                        <owl:sameAs rdf:resource="{concat('http://lobid.org/resource/',concat(replace(replace(.,'\([^\)]+\)',''),'HBZ',''),'/about'))}" />
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
                        <!-- TODO CHECK -->
                        <!-- <xsl:value-of select="normalize-space(ext:deleteFromString(./text(),'/$|:$'))"/> -->
                        <xsl:value-of select="normalize-space(replace(./text(),'/$|:$',''))"/>
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
                <!-- Einheitstitle -->
                <xsl:for-each select="//marc:datafield[@tag='130']/marc:subfield[@code='a']">
                    <dct:alternative>
                        <xsl:value-of select="normalize-space(replace(./text(),'/$|:$',''))"/>
                    </dct:alternative>
                </xsl:for-each>
                <xsl:for-each select="//marc:datafield[@tag='240']/marc:subfield[@code='a']">
                    <dct:alternative>
                        <xsl:value-of select="normalize-space(replace(./text(),'/$|:$',''))"/>
                    </dct:alternative>
                </xsl:for-each>

                <!-- Kurztitel -->
                <xsl:for-each select="//marc:datafield[@tag='210']/marc:subfield[@code='a']">
                    <bibo:shortTitle>
                        <xsl:value-of select="normalize-space(replace(./text(),'/$|:$',''))"/>
                    </bibo:shortTitle>
                </xsl:for-each>

                <!-- Subtitle -->
                <xsl:for-each select="//marc:datafield[@tag='245']/marc:subfield[@code='b']">
                    <isbd:P1006>
                        <!-- TODO CHECK -->
                        <!-- <xsl:value-of select="normalize-space(ext:deleteFromString(./text(),'/$'))" /> -->
                        <xsl:value-of select="normalize-space(replace(./text(),'/$',''))" />
                    </isbd:P1006>
                </xsl:for-each>
                <!-- Paralleltitel -->
                <xsl:for-each select="//marc:datafield[@tag='246' and @ind2 and ind2='1']/marc:subfield[@code='a']">
                    <dct:alternative> 
                        <xsl:value-of select="normalize-space(replace(./text(),'/$',''))" />
                    </dct:alternative>
                </xsl:for-each>
            
                <xsl:for-each select="//marc:datafield[@tag='250']/marc:subfield[@code='a']">
                    <bibo:edition>
                        <xsl:value-of select="normalize-space(./text())" />
                    </bibo:edition>
                </xsl:for-each>
            
                <xsl:for-each select="//marc:datafield[@tag='490']/marc:subfield[@code='a']">
                    <xsl:if test="//marc:datafield[@tag='490']/marc:subfield[@code='v']">
                        <dct:bibliographicCitation>
                            <xsl:value-of select="normalize-space(concat(./text(),'_:_',//marc:datafield[@tag='490']/marc:subfield[@code='v']/text()))" />
                        </dct:bibliographicCitation>
                    </xsl:if>
                </xsl:for-each>

                <!-- 
                Volume (iterate over all volume numbers: 773$g, 810$v, 830$v)
                Important: If you change something here, remember to change the 'Some links from Collections to their items' part above! 
                           Otherwise, the generated URIs will be inconsistent.
                -->
                <xsl:for-each select="//marc:datafield[@tag='773']/marc:subfield[@code='g']/text()|
                                  //marc:datafield[@tag='830']/marc:subfield[@code='v']/text()|
                                  //marc:datafield[@tag='810']/marc:subfield[@code='v']/text()">  
                    <!-- in 773, volume numbers are in $g, in 810 & 830 in $v-->
                    <xsl:choose>
                        <xsl:when test="string-length(replace(../../marc:subfield[@code='w'],'\([^\)]+\)','')) &gt; 0 and 
                                    (string-length(replace(../../marc:subfield[@code='g'],'\D','')) &gt; 0 or string-length(replace(../../marc:subfield[@code='v'],'\D','')) &gt; 0)">
                            <xsl:choose>
                                <xsl:when test="string-length(replace(../../marc:subfield[@code='g'],'\D','')) &gt; 0">
                                    <owl:sameAs rdf:resource="{concat($docIdUriPrefix,replace(../../marc:subfield[@code='w'],'\([^\)]+\)',''))}/vol/{replace(../../marc:subfield[@code='g'],'\D','')}"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <owl:sameAs rdf:resource="{concat($docIdUriPrefix,replace(../../marc:subfield[@code='w'],'\([^\)]+\)',''))}/vol/{replace(../../marc:subfield[@code='v'],'\D','')}"/>
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
            
                <!-- Differenzierte Angaben zur Quelle: Bandzählung, Heftzählung, Tag, Monat, Jahr) -->
               <xsl:for-each select="//marc:datafield[@tag='773']/marc:subfield[@code='g']">
                    <dct:bibliographicCitation>
                        <xsl:value-of select="normalize-space(./text())" />
                    </dct:bibliographicCitation>
                </xsl:for-each>
            
                <!-- Link up -->
                <!-- TODO CHECK -->
                <!--
                <xsl:for-each select="//marc:datafield[@tag='773']/marc:subfield[@code='w']/text()|//marc:datafield[@tag='830']/marc:subfield[@code='w']/text()|//marc:datafield[@tag='810']/marc:subfield[@code='w']/text()">
                    <dct:isPartOf rdf:resource="{concat($docIdUriPrefix,ext:deleteFromString(.,'\([^\)]+\)'))}" />
                </xsl:for-each>
                -->
                <xsl:for-each select="//marc:datafield[@tag='773']/marc:subfield[@code='w']/text()|//marc:datafield[@tag='830']/marc:subfield[@code='w']/text()|//marc:datafield[@tag='810']/marc:subfield[@code='w']/text()">
                    <xsl:choose>
                        <xsl:when test="starts-with(.,'(DE-576)')">
                            <dct:isPartOf rdf:resource="{concat($bszUriPrefix,replace(.,'\([^\)]+\)',''))}" />
                        </xsl:when>
                        <xsl:otherwise>
                            <dct:isPartOf rdf:resource="{concat($docIdUriPrefix,replace(.,'\([^\)]+\)',''))}" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <!-- Authors / Creators -->
                <xsl:for-each select="//marc:datafield[@tag='100']/marc:subfield[@code='0']/text()">
                    <xsl:variable name="gnd_link" select="concat($gndUriPrefix, replace(.,'(^\(DE-588\)(\S+)$)','$2'),'/about')" />
                    <!-- <dct:creator rdf:resource="{concat($gndUriPrefix, ext:getGndNumber(.))}" /> -->
                    <xsl:if test="starts-with(.,'(DE-588)')">
                        <dct:creator rdf:resource="{concat($gndUriPrefix, replace(.,'(^\(DE-588\)(\S+)$)','$2'),'/about')}" />
                    </xsl:if>
                    <xsl:if test="starts-with(.,'(DE-576)')">
                        <dct:creator rdf:resource="{concat($bszUriPrefix, replace(.,'(^\(DE-576\)(\S+)$)','$2'))}" />
                    </xsl:if>
                    <!-- Write Marc Relator Code Triples -->
                    <xsl:if test="../../marc:subfield[@code='4']/text()">
                        <xsl:if test="starts-with(.,'(DE-588)')">
                            <bibo:editor rdf:resource="{$gnd_link}" />
                            <xsl:value-of select="concat('&lt;marcrel:',../../marc:subfield[@code='4']/text(),' rdf:resource=&#34;',$gnd_link,'&#34; /&gt;')" disable-output-escaping="yes" />
                        </xsl:if>
                    </xsl:if>
                </xsl:for-each>
            
                <!-- Contributors -->
                <!-- MARC Code List for Relators http://www.loc.gov/marc/relators/relacode.html -->
                <xsl:for-each select="//marc:datafield[@tag='700']/marc:subfield[@code='0']/text()">
                    <xsl:variable name="gnd_link" select="concat($gndUriPrefix, replace(.,'(^\(DE-588\)(\S+)$)','$2'),'/about/rdf')" />
                    <xsl:choose>
                        <xsl:when test="../../marc:subfield[@code='e']/text() != 'Hrsg.'">
                            <!-- Write Marc Relator Code Triples -->
                            <xsl:if test="../../marc:subfield[@code='4']/text()">
                                <xsl:if test="starts-with(.,'(DE-588)')">
                                    <dct:contributor rdf:resource="{$gnd_link}" />
                                    <xsl:value-of select="concat('&lt;marcrel:',../../marc:subfield[@code='4']/text(),' rdf:resource=&#34;',$gnd_link,'&#34; /&gt;')" disable-output-escaping="yes" />
                                </xsl:if>
                            </xsl:if>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="../../marc:subfield[@code='4']/text()">
                                <!-- Write Marc Relator Code Triples -->
                                <xsl:if test="starts-with(.,'(DE-588)')">
                                    <bibo:editor rdf:resource="{$gnd_link}" />
                                    <xsl:value-of select="concat('&lt;marcrel:',../../marc:subfield[@code='4']/text(),' rdf:resource=&#34;',$gnd_link,'&#34; /&gt;')" disable-output-escaping="yes" />
                                </xsl:if>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>

                <xsl:for-each select="//marc:datafield[@tag='770']/marc:subfield[@code='w']/text()">
                    <xsl:if test="string-length(normalize-space(.)) &gt; 0">
                        <!-- TODO -->
                        <!-- Test file /usr/local/mdma/extracted/000/201405050230/010_finc-tit.mrc -->
                        <xsl:choose>
                            <xsl:when test="starts-with(.,'(DE-576)')">
                                <dct:isPartOf rdf:resource="{concat('http://hub.culturegraph.org/resource/BSZ-',substring(.,9))}" />
                            </xsl:when>
                            <xsl:when test="starts-with(.,'(DE-600)')">
                                <dct:isPartOf rdf:resource="{concat('http://ld.zdb-services.de/resource/',substring(.,9))}" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:if>
                </xsl:for-each>
                <xsl:for-each select="//marc:datafield[@tag='775']/marc:subfield[@code='w']/text()">
                    <xsl:if test="string-length(normalize-space(.)) &gt; 0">
                        <!-- TODO -->
                        <!-- Test file /usr/local/mdma/extracted/000/201405050230/010_finc-tit.mrc -->
                        <xsl:choose>
                            <xsl:when test="starts-with(.,'(DE-576)')">
                                <dct:hasVersion rdf:resource="{concat('http://hub.culturegraph.org/resource/BSZ-',substring(.,9))}" />
                            </xsl:when>
                            <xsl:when test="starts-with(.,'(DE-600)')">
                                <dct:hasVersion rdf:resource="{concat('http://ld.zdb-services.de/resource/',substring(.,9))}" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:if>
                </xsl:for-each>

                <!-- Schlagworte (SWD, LCSH) -->
                <xsl:for-each select="//marc:datafield[@tag='600']
                    | //marc:datafield[@tag='610']
                    | //marc:datafield[@tag='611']
                    | //marc:datafield[@tag='630']
                    | //marc:datafield[@tag='648']
                    | //marc:datafield[@tag='650']
                    | //marc:datafield[@tag='651']
                    | //marc:datafield[@tag='652']
                    | //marc:datafield[@tag='653']
                    | //marc:datafield[@tag='654']
                    | //marc:datafield[@tag='656']
                    | //marc:datafield[@tag='657']
                    | //marc:datafield[@tag='658']
                    | //marc:datafield[@tag='659']
                    | //marc:datafield[@tag='689']">
                    <xsl:choose>
                        <!-- GND-Numbers are transformed to GND-URIs -->
                        <xsl:when test="starts-with(./marc:subfield[@code='0']/text(),'(DE-588)')">
                            <dct:subject rdf:resource="{concat($gndUriPrefix, substring(./marc:subfield[@code='0']/text(),9),'/about')}" />
                        </xsl:when>
                        <xsl:when test="starts-with(./marc:subfield[@code='0']/text(),'(DE-576)')">
                            <dct:subject rdf:resource="{concat($bszUriPrefix, substring(./marc:subfield[@code='0']/text(),9))}" />
                        </xsl:when>
                        <!-- If no number available, print the subject heading into a String-literal -->
                        <xsl:when test="./marc:subfield[@code='a']/text() and ./marc:subfield[@code='2']/text() = 'gnd'">
                            <dc:subject><xsl:value-of select="normalize-space(translate(./marc:subfield[@code='a']/text(),'.',''))"/></dc:subject>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- Check if the preferredLabel can be mapped to a LCSH URI-->
                            <xsl:choose>
                                <xsl:when test="@tag='650'">
                                    <dct:subject rdf:resource="{resolve-uri($sparqlEndpointLCSH, encode-for-uri(translate(./marc:subfield[@code='a']/text(),'.','')))}" />
                                </xsl:when>
                                <!-- If no LCSH-URI can be matched (or the preferredLabel is ambiguous) just write a dc:subject with the plain text-->
                                <xsl:when test="string-length(translate(./marc:subfield[@code='a']/text(),'.','')) &gt; 0">
                                    <dc:subject><xsl:value-of select="normalize-space(translate(./marc:subfield[@code='a']/text(),'.',''))" /></dc:subject>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <!-- Klassifikationen (RVK, DDC, SSG-Nummer) -->
                <!-- ToDo: Die URIs für rvk & ssg sind fiktiv -> Wann gibt es das als LOD? -->
                <xsl:for-each select="//marc:datafield[@tag='082']/marc:subfield[@code='a']/text()|//marc:datafield[@tag='089']/marc:subfield[@code='c']/text()">
                    <xsl:choose>
                        <xsl:when test="matches(replace(translate(.,'/',''),'\s.+$',''),'^\d{3}(\.\d{1,4})*$')">
                            <dct:subject rdf:resource="{concat(concat('http://dewey.info/class/',replace(translate(.,'/',''),'\s.+$','')),'/about')}" />
                        </xsl:when>
                        <xsl:otherwise>
                            <dct:subject rdf:resource="{concat(concat('http://dewey.info/class/',substring(replace(translate(.,'/',''),'\s.+$',''),0,6)),'/about')}" />
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- Additional output of DDCs as literal because some users prefer that to dewey.info-URIs 
                        (and those are sometimes not possible; e.g. synthetic notations)
                        Fortunately, there is a datatype for those: dct:ddc
                    -->
                    <dc:subject rdf:datatype="http://purl.org/dc/terms/DDC"><xsl:value-of select="translate(.,'/','')"/></dc:subject>
                </xsl:for-each>
                <xsl:for-each select="//marc:datafield[@tag='084']/marc:subfield[@code='a']/text()">
                    <xsl:choose>
                        <xsl:when test="../../marc:subfield[@code='2']/text() = 'ssgn'">
                            <dct:subject rdf:resource="{concat('http://webis.sub.uni-hamburg.de/webis/index.php/',translate(.,',','.'))}" />
                        </xsl:when>
                        <xsl:when test="../../marc:subfield[@code='2']/text() = 'rvk'">
                            <dct:subject rdf:resource="{replace($rvkUriPrefix,'\*\*rvk\*\*',.)}" />
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
                        <xsl:value-of select="replace(.,'-','')" />
                    </bibo:isbn>
                </xsl:for-each>
                <xsl:for-each select="//marc:datafield[@tag='022']/marc:subfield[@code='a']/text()| //marc:datafield[@tag='022']/marc:subfield[@code='y']">
                    <xsl:if test="not(contains(.,'ZBTBA'))">
                        <bibo:issn>
                            <xsl:value-of select="." />
                        </bibo:issn>
                    </xsl:if>
                </xsl:for-each>
            
                <!-- Extent - Umfangsangabe -->
                <xsl:for-each select="//marc:datafield[@tag='300']">
                    <dct:extent>
                        <xsl:for-each select="./marc:subfield[@code='a']">
                            <xsl:value-of select="normalize-space(concat(normalize-space(translate(.,';:','')),' '))" />
                        </xsl:for-each>
                    </dct:extent>
                    <isbd:P1053>
                        <xsl:for-each select="./marc:subfield[@code='a']">
                            <xsl:value-of select="normalize-space(concat(normalize-space(translate(.,';:','')),' '))" />
                        </xsl:for-each>
                    </isbd:P1053>
                </xsl:for-each>

                <xsl:if test="$lang008">
                    <dct:language rdf:resource="{$langUri008}"/>
                </xsl:if>
                <xsl:for-each select="//marc:datafield[@tag='041']/marc:subfield[@code='a']/text()|//marc:datafield[@tag='041']/marc:subfield[@code='h']/text()">
                    <xsl:if test="$lang008 != .">
                        <dct:language rdf:resource="{concat('http://id.loc.gov/vocabulary/iso639-2/',.)}" />
                    </xsl:if>
                </xsl:for-each>

                <!-- Publication event -->
                <xsl:for-each select="//marc:datafield[@tag='260']">
                    <xsl:if test="normalize-space(translate(./marc:subfield[@code='a']/text(),':,',''))">
                        <isbd:P1016>
                            <xsl:value-of select="normalize-space(translate(./marc:subfield[@code='a']/text(),':,',''))" />
                        </isbd:P1016>
                        <xsl:if test="string-length($marcCountryCode) > 1 and not(starts-with($marcCountryCode,'xx'))">
                            <rdagr1:placeOfPublication rdf:resource="{concat('http://id.loc.gov/vocabulary/countries/',translate(substring(//marc:controlfield[@tag='008'],16,3),'ä',''))}" />
                        </xsl:if>
                        <xsl:if test="//marc:datafield[@tag='044']/marc:subfield[@code='c']/text()">
                            <geonames:countryCode>
                                <xsl:value-of select="substring(//marc:datafield[@tag='044']/marc:subfield[@code='c']/text(),4,2)"/>
                            </geonames:countryCode>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="normalize-space(translate(./marc:subfield[@code='b']/text(),',',''))">
                        <dct:publisher>
                            <xsl:value-of select="normalize-space(translate(normalize-space(translate(./marc:subfield[@code='b']/text(),',','')),';',''))" />
                        </dct:publisher>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="$pubYearInt1">
                            <dct:issued rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
                                <xsl:value-of select="$pubYearInt1" />
                            </dct:issued>
                        </xsl:when>
                        <xsl:when test="./marc:subfield[@code='c']/text()">
                            <dct:issued>
                                <xsl:value-of select="./marc:subfield[@code='c']/text()" />
                            </dct:issued>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:if test="$pubYearInt2 and string-length(normalize-space($pubYearInt2)) &gt; 0 and $pubYearInt2 != '9999'">
                        <dct:issued rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
                            <xsl:value-of select="$pubYearInt2" />
                        </dct:issued>
                    </xsl:if>
                </xsl:for-each>

                <!-- Link to frbr:Items (frbr:exemplar) -->
                <xsl:for-each select="//marc:datafield[@tag='049']/marc:subfield[@code='a']/text()">
                    <xsl:if test="not(. = 'HVR01' or . = 'LGW01' or . = 'OGB01' or . = 'VAN01' or . = 'VGA01' or . = 'VGB01' or . = 'VGH01' or . = 'VGM01' or . = 'VGR01' or . = 'VGW01')">
                        <frbr:exemplar rdf:resource="{$exemplarUriExLink}" />
                    </xsl:if>
                </xsl:for-each>
            
                <!-- MARC general notes as dc:descriptions -->
                <xsl:for-each select="//marc:datafield[@tag='500']/marc:subfield[@code='a']|//marc:datafield[@tag='245']/marc:subfield[@code='c']">
                    <dct:description>
                        <xsl:value-of select="normalize-space(./text())" />
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
                <xsl:choose>
                    <xsl:when test="string-length(replace(../../marc:subfield[@code='w'],'\([^\)]+\)','')) &gt; 0 and 
                                    (string-length(replace(../../marc:subfield[@code='g'],'\D','')) &gt; 0 or string-length(replace(../../marc:subfield[@code='v'],'\D','')) &gt; 0)">
                        <rdf:Description rdf:about="{concat($docIdUriPrefix,replace(../../marc:subfield[@code='w'],'\([^\)]+\)',''))}">
                            <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Document" />
                            <xsl:choose>
                                <xsl:when test="string-length(replace(../../marc:subfield[@code='g'],'\D','')) &gt; 0">
                                    <dct:hasPart rdf:resource="{concat($docIdUriPrefix,replace(../../marc:subfield[@code='w'],'\([^\)]+\)',''))}/vol/{replace(../../marc:subfield[@code='g'],'\D','')}" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <dct:hasPart rdf:resource="{concat($docIdUriPrefix,replace(../../marc:subfield[@code='w'],'\([^\)]+\)',''))}/vol/{replace(../../marc:subfield[@code='v'],'\D','')}" /> 
                                </xsl:otherwise>
                            </xsl:choose>
                        </rdf:Description>
                        <!-- Volume-URIs -->
                        <xsl:choose>
                            <xsl:when test="string-length(replace(../../marc:subfield[@code='g'],'\D','')) &gt; 0">
                                <rdf:Description rdf:about="{concat($docIdUriPrefix,replace(../../marc:subfield[@code='w'],'\([^\)]+\)',''))}/vol/{replace(../../marc:subfield[@code='g'],'\D','')}">
                                    <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Document" />
                                    <bibo:volume>
                                        <xsl:value-of select="." />
                                    </bibo:volume>
                                    <owl:sameAs rdf:resource="{$titleUri}"/>
                                </rdf:Description>
                            </xsl:when>
                            <xsl:otherwise>
                                <rdf:Description rdf:about="{concat($docIdUriPrefix,replace(../../marc:subfield[@code='w'],'\([^\)]+\)',''))}/vol/{replace(../../marc:subfield[@code='v'],'\D','')}">
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
                    <xsl:when test="string-length(replace(../../marc:subfield[@code='w'],'\([^\)]+\)','')) &gt; 0">
                        <rdf:Description rdf:about="{concat($docIdUriPrefix,replace(../../marc:subfield[@code='w'],'\([^\)]+\)',''))}">
                            <rdf:type rdf:resource="http://xmlns.com/foaf/0.1/Document" />
                            <dct:hasPart rdf:resource="{$titleUri}" />
                        </rdf:Description> 
                    </xsl:when>
                </xsl:choose>
                       
            </xsl:for-each>
            
            <!-- Description of temporary SSGs and RVKs -->
<!--            <xsl:for-each select="//marc:datafield[@tag='084']/marc:subfield[@code='a']/text()">
                <xsl:choose>
                    <xsl:when test="../../marc:subfield[@code='2']/text() = 'ssgn'">
                        <skos:Concept rdf:about="{concat($ssgUriPrefix,translate(.,',','.'))}">
                            <foaf:homepage rdf:resource="{concat('http://webis.sub.uni-hamburg.de/webis/index.php/',translate(.,',','.'))}" />
                        </skos:Concept>
                    </xsl:when>
                    <xsl:when test="../../marc:subfield[@code='2']/text() = 'rvk'">
                        <skos:Concept rdf:about="{replace($rvkUriPrefix,'\*\*rvk\*\*',.)}">
                            <foaf:homepage rdf:resource="{$uriPrefix}" />
                        </skos:Concept>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>-->
            
            <!-- Holdings: frbr:Items-->
            <xsl:for-each select="//marc:datafield[@tag='049']/marc:subfield[@code='a']/text()">
                <xsl:if test="not(. = 'HVR01' or . = 'LGW01' or . = 'OGB01' or . = 'VAN01' or . = 'VGA01' or . = 'VGB01' or . = 'VGH01' or . = 'VGM01' or . = 'VGR01' or . = 'VGW01')">
                    <frbr:Item rdf:about="{$exemplarUri}">
                        <xsl:choose>
                            <xsl:when test="$bibUri">
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
                <rdf:Description rdf:about="{concat($isbnUriPrefix,.)}">
                    <owl:sameAs rdf:resource="{concat($docIdUriPrefix,$docId)}" />
                </rdf:Description>
            </xsl:for-each>
            <xsl:for-each select="//marc:datafield[@tag='022']/marc:subfield[@code='a']/text()|//marc:datafield[@tag='022']/marc:subfield[@code='y']">
                <xsl:if test="not(contains(.,'ZBTBA'))">
                    <rdf:Description rdf:about="{concat($issnUriPrefix,.)}">
                        <owl:sameAs rdf:resource="{concat($docIdUriPrefix,$docId)}" />
                    </rdf:Description>
                </xsl:if>
            </xsl:for-each>
        </rdf:RDF>
    </xsl:template>
    
    <xsl:template match="marc:leader">
    </xsl:template>

    <xsl:template match="marc:controlfield">
    </xsl:template>

    <xsl:template match="//marc:datafield">
    </xsl:template>
        
</xsl:stylesheet>