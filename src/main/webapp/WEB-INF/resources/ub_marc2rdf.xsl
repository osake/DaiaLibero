<?xml version="1.0" encoding="UTF-8"?>
<!--
    Document    : ub_marc2rdf.xsl
    Description : Transforms MARCXML to RDF/XML.
    Institution : Leipzig University Library
    Project     : Project finc http://finc.info
    Author      : Polichronis Tsolakidis <tsolakidis@ub.uni-leipzig.de>
    License     : GNU General Public License http://opensource.org/licenses/gpl-3.0.html

    Eine Kombination aus 'marc2rdf.xsl' und den Empfehlungen
    in https://wiki.dnb.de/display/DINIAGKIM/MARC+21-RDF-Mapping

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
    xmlns:rdau="http://rdaregistry.info/Elements/u/"
    xmlns:rda="http://rdvocab.info/Elements/"
    xmlns:umbel="http://umbel.org/umbel#"
    version="1.0">

    <xsl:output method="xml" encoding="UTF-8" indent="yes" />

    <xsl:param name="itemBaseUri">
        <xsl:text>http://localhost:8088/item/</xsl:text>
        <!-- <xsl:text>http://data.ub.uni-leipzig.de/item/</xsl:text> -->
    </xsl:param>
    
    <xsl:param name="docId">
        <xsl:value-of select="//marc:controlfield[@tag='001']/text()" />
    </xsl:param>

    <xsl:template match="/">
        <xsl:if test="string-length($docId) > 1">
            <xsl:call-template name="mainMapping"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="mainMapping">
        <rdf:RDF>
            <rdf:Description rdf:about="{concat('finc:',$docId)}">
        
                <!-- Medientypen -->
                <!-- *********** -->
                <xsl:for-each select="//marc:leader">

                    <xsl:choose>
                        <xsl:when test="substring(.,8,1) = 'a'">
                            <rdf:type rdf:resource="http://purl.org/ontology/bibo/Article" />
                        </xsl:when>
                        <xsl:when test="substring(.,8,1) = 'b'">
                            <rdf:type rdf:resource="http://purl.org/ontology/bibo//Issue" />
                        </xsl:when>
                        <!-- 
                        <xsl:when test="substring(.,8,1) = 's'">
                            <xsl:if test="not(substring(//marc:controlfield[@tag='008'],22,1) ='m')">
                                <rdf:type rdf:resource="http://purl.org/ontology/bibo/Periodical" />
                            </xsl:if>
                        </xsl:when>
                        -->
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="substring(//marc:controlfield[@tag='007'],1,1) = 'f'">
                            <rdf:type rdf:resource="http://purl.org/library/BrailleBook" />
                        </xsl:when>
                    </xsl:choose>
                    
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
                </xsl:for-each> <!-- Leader -->

                <!-- Title -->
                <!-- Hauptsachtitel (HST) -->
                <xsl:if test="//marc:datafield[@tag='245']/marc:subfield[@code='a']/text()">
                    <dc:title>
                        <xsl:value-of select="//marc:datafield[@tag='245']/marc:subfield[@code='a']/text()" />
                    </dc:title>
                </xsl:if>

                <!-- Zusatz zum HST -->
                <xsl:if test="//marc:datafield[@tag='245']/marc:subfield[@code='b']/text()">
                    <rdau:P60493>
                        <xsl:value-of select="//marc:datafield[@tag='245']/marc:subfield[@code='b']/text()" />
                    </rdau:P60493>
                </xsl:if>
                <!-- Zusatz zum HST -->
                <xsl:if test="//marc:datafield[@tag='245']/marc:subfield[@code='n'] and //marc:datafield[@tag='245']/marc:subfield[@code='p']">
                    <rdau:P60493>
                        <xsl:value-of select="concat(//marc:datafield[@tag='245']/marc:subfield[@code='n'],'_',//marc:datafield[@tag='245']/marc:subfield[@code='p'])" />
                    </rdau:P60493>
                </xsl:if>
                <!-- Einheitstitel -->
                <xsl:if test="//marc:datafield[@tag='130']/marc:subfield[@code='a']/text()">
                    <dct:alternative>
                        <xsl:value-of select="//marc:datafield[@tag='130']/marc:subfield[@code='a']/text()" />
                    </dct:alternative>
                </xsl:if>
                <xsl:if test="//marc:datafield[@tag='240']/marc:subfield[@code='a']/text()">
                    <dct:alternative>
                        <xsl:value-of select="//marc:datafield[@tag='240']/marc:subfield[@code='a']/text()" />
                    </dct:alternative>
                </xsl:if>
                <!-- Kurztitel -->
                <xsl:if test="//marc:datafield[@tag='210']/marc:subfield[@code='a']/text()">
                    <bibo:shortTitle>
                        <xsl:value-of select="//marc:datafield[@tag='210']/marc:subfield[@code='a']/text()" />
                    </bibo:shortTitle>
                </xsl:if>
                <!-- Paralleltitel -->
                <xsl:if test="//marc:datafield[@tag='246' and @ind2='1']/marc:subfield[@code='a']/text()">
                    <dct:alternative>
                        <xsl:value-of select="//marc:datafield[@tag='210' and @ind2='1']/marc:subfield[@code='a']/text()" />
                    </dct:alternative>
                </xsl:if>
                
                <!-- Personen und Körperschaften -->
                <!-- *************************** -->
                <xsl:choose>
                    <!--Personenname (NID) -->
                    <xsl:when test="starts-with(//marc:datafield[@tag='100']/marc:subfield[@code='0']/text(),'(DE-588)')">
                        <dct:creator rdf:resource="{concat('http://d-nb.info/gnd/',substring(//marc:datafield[@tag='100']/marc:subfield[@code='0']/text(),9))}" />
                    </xsl:when>
                    <!-- Personenname (Literal), nur ausweisen, wenn 100$0 nicht besetzt ist -->
                    <xsl:otherwise>
                        <xsl:if test="//marc:datafield[@tag='100']/marc:subfield[@code='a']/text()">
                            <dc:creator><xsl:value-of select="//marc:datafield[@tag='100']/marc:subfield[@code='a']/text()"/></dc:creator>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <!--Körperschaftsname (IDN) -->
                    <xsl:when test="starts-with(//marc:datafield[@tag='110']/marc:subfield[@code='0']/text(),'(DE-588)')">
                        <dct:creator rdf:resource="{concat('http://d-nb.info/gnd/',substring(//marc:datafield[@tag='110']/marc:subfield[@code='0']/text(),9))}" />
                    </xsl:when>
                    <!-- Körperschaftsname (Literal), nur ausweisen, wenn 110$0 nicht besetzt ist -->
                    <xsl:otherwise>
                        <xsl:if test="//marc:datafield[@tag='110']/marc:subfield[@code='a']/text()">
                            <dc:creator><xsl:value-of select="//marc:datafield[@tag='110']/marc:subfield[@code='a']/text()"/></dc:creator>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <!--Kongressname (NID) -->
                    <xsl:when test="starts-with(//marc:datafield[@tag='111']/marc:subfield[@code='0']/text(),'(DE-588)')">
                        <dct:creator rdf:resource="{concat('http://d-nb.info/gnd/',substring(//marc:datafield[@tag='111']/marc:subfield[@code='0']/text(),9))}" />
                    </xsl:when>
                    <!-- Kongressname (Literal), nur ausweisen, wenn 111$0 nicht besetzt ist -->
                    <xsl:otherwise>
                        <xsl:if test="//marc:datafield[@tag='111']/marc:subfield[@code='a']/text()">
                            <dc:creator><xsl:value-of select="//marc:datafield[@tag='111']/marc:subfield[@code='a']/text()"/></dc:creator>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <!-- Personenname (NID) -->
                    <xsl:when test="starts-with(//marc:datafield[@tag='700']/marc:subfield[@code='0']/text(),'(DE-588)')">
                        <dct:contributor rdf:resource="{concat('http://d-nb.info/gnd/',substring(//marc:datafield[@tag='700']/marc:subfield[@code='0']/text(),9))}" />
                    </xsl:when>
                    <!-- Personenname (Literal), nur ausweisen, wenn 700$0 nicht besetzt ist -->
                    <xsl:otherwise>
                        <xsl:if test="//marc:datafield[@tag='700']/marc:subfield[@code='a']/text()">
                            <dc:contributor><xsl:value-of select="//marc:datafield[@tag='700']/marc:subfield[@code='a']/text()"/></dc:contributor>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <!-- Körperschaftsname (NID) -->
                    <xsl:when test="starts-with(//marc:datafield[@tag='710']/marc:subfield[@code='0']/text(),'(DE-588)')">
                        <dct:contributor rdf:resource="{concat('http://d-nb.info/gnd/',substring(//marc:datafield[@tag='710']/marc:subfield[@code='0']/text(),9))}" />
                    </xsl:when>
                    <!-- Körperschaftsname (Literal), nur ausweisen, wenn 710$0 nicht besetzt ist -->
                    <xsl:otherwise>
                        <xsl:if test="//marc:datafield[@tag='710']/marc:subfield[@code='a']/text()">
                            <dc:contributor><xsl:value-of select="//marc:datafield[@tag='710']/marc:subfield[@code='a']/text()"/></dc:contributor>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:choose>
                    <!-- Kongressname (NID) -->
                    <xsl:when test="starts-with(//marc:datafield[@tag='711']/marc:subfield[@code='0']/text(),'(DE-588)')">
                        <dct:contributor rdf:resource="{concat('http://d-nb.info/gnd/',substring(//marc:datafield[@tag='711']/marc:subfield[@code='0']/text(),9))}" />
                    </xsl:when>
                    <!-- Kongressname (Literal), nur ausweisen, wenn 711$0 nicht besetzt ist -->
                    <xsl:otherwise>
                        <xsl:if test="//marc:datafield[@tag='711']/marc:subfield[@code='a']/text()">
                            <dc:contributor><xsl:value-of select="//marc:datafield[@tag='711']/marc:subfield[@code='a']/text()"/></dc:contributor>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
                
                <!-- Orts-, Verlags- und Datumsangaben -->
                <!-- ********************************* -->
                <xsl:for-each select="//marc:datafield[@tag='260']">
                    <xsl:if test="./marc:subfield[@code='a'] and ./marc:subfield[@code='b'] and ./marc:subfield[@code='c']">
                        <rda:publicationStatement>
                            <xsl:value-of select="concat(./marc:subfield[@code='a']/text(),./marc:subfield[@code='b']/text(),./marc:subfield[@code='c']/text())"/>
                        </rda:publicationStatement>
                    </xsl:if>
                </xsl:for-each>
                <xsl:for-each select="//marc:datafield[@tag='260']/marc:subfield[@code='a']">
                    <rdau:P60333>
                        <xsl:value-of select="normalize-space(translate(./text(),'[:]',''))"/>
                    </rdau:P60333>
                </xsl:for-each>
                <xsl:for-each select="//marc:datafield[@tag='260']/marc:subfield[@code='b']">
                    <dc:publisher>
                        <xsl:value-of select="normalize-space(translate(./text(),',',''))"/>
                    </dc:publisher>
                </xsl:for-each>
                <xsl:for-each select="//marc:datafield[@tag='260']/marc:subfield[@code='c']">
                    <dct:issued>
                        <xsl:value-of select="normalize-space(translate(./text(),',',''))"/>
                    </dct:issued>
                </xsl:for-each>
                <xsl:if test="translate(substring(//marc:controlfield[@tag='008'],8,4), 'äu','')">
                    <dct:issued rdf:datatype="http://www.w3.org/2001/XMLSchema#int">
                        <xsl:value-of select="translate(substring(//marc:controlfield[@tag='008'],8,4), 'äu','')" />
                    </dct:issued>
                </xsl:if>

                <!-- Identifier -->
                <!-- ********** -->
                <xsl:for-each select="//marc:datafield[@tag='035']/marc:subfield[@code='a']">
                    <xsl:variable name="curi">
                        <xsl:text>http://hub.culturegraph.org/resource/</xsl:text>
                    </xsl:variable>
                    <xsl:variable name="isil" select="substring(./text(),1,8)" />
                    <xsl:variable name="id"   select="substring(./text(),9)" />
                    <!-- <xsl:value-of select="$isil" /><xsl:value-of select="$id" /> -->
                    <xsl:choose>
                        <xsl:when test="starts-with($isil,'(DE-605)')">
                            <owl:sameAs rdf:resource="{concat($curi,'HBZ-',replace($id,'HBZ',''))}" />
                        </xsl:when>
                        <xsl:when test="starts-with($isil,'(DE-603)')">
                            <owl:sameAs rdf:resource="{concat($curi,'HEB-',replace($id,'HEB',''))}" />
                        </xsl:when>
                        <xsl:when test="starts-with($isil,'(DE-576)')">
                            <owl:sameAs rdf:resource="{concat($curi,'BSZ-',replace($id,'BSZ',''))}" />
                        </xsl:when>
                        <xsl:when test="starts-with($isil,'(DE-604)')">
                            <owl:sameAs rdf:resource="{concat($curi,'BVB-',replace($id,'BVB',''))}" />
                        </xsl:when>
                        <xsl:when test="starts-with($isil,'(DE-601)')">
                            <owl:sameAs rdf:resource="{concat($curi,'GBV-',replace($id,'GBV',''))}" />
                        </xsl:when>
                        <xsl:when test="starts-with($isil,'(DE-600)')">
                            <owl:sameAs rdf:resource="{concat($curi,'ZDB-',replace($id,'ZDB',''))}" />
                        </xsl:when>
                        <xsl:when test="starts-with(./text(),'(DE-599)DNB')">
                            <owl:sameAs rdf:resource="{concat($curi,'DNB-',replace($id,'DNB',''))}" />
                        </xsl:when>
                        <xsl:when test="starts-with(./text(),'(DE-599)ZDB')">
                            <owl:sameAs rdf:resource="{concat('http://ld.zdb-services.de/data/',replace($id,'ZDB',''))}" />
                        </xsl:when>
                        <xsl:when test="contains(./text(),'OBV')">
                            <owl:sameAs rdf:resource="{concat($curi,'OBV-',replace($id,'OBV',''))}" />
                        </xsl:when>
                        <!-- OCLC-Nummer -->
                        <xsl:when test="starts-with(./text(),'(OCoLC)')">
                            <bibo:oclcnum rdf:resource="{normalize-space(substring(./text(),8))}" />
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
                
                <!-- Digital Object Identifier (DOI) -->
                <xsl:for-each select="//marc:datafield[@tag='024' and @ind1='7']">
                    <xsl:if test="./marc:subfield[@code='a'] and ./marc:subfield[@code='2'] = 'doi'">
                        <umbel:isLike rdf:resource="{concat('http://dx.doi.org/',replace(./marc:subfield[@code='a'],'/','%2F'))}" />
                    </xsl:if>
                    <!-- URN -->
                    <xsl:if test="./marc:subfield[@code='a'] and ./marc:subfield[@code='2'] = 'um'">
                        <umbel:isLike rdf:resource="{concat('http://nbn-resolving.de/',replace(./marc:subfield[@code='a'],'/','%2F'))}" />
                    </xsl:if>
                </xsl:for-each>
                
                <!-- International Standard Serial Number -->
                <xsl:for-each select="//marc:datafield[@tag='022']/marc:subfield[@code='a']">
                    <xsl:choose>
                        <xsl:when test="substring(//marc:controlfield[@tag='007'],1,1) = 'c'">
                            <bibo:eissn><xsl:value-of select="./text()" /></bibo:eissn>
                        </xsl:when>
                        <xsl:otherwise>
                            <bibo:issn><xsl:value-of select="./text()" /></bibo:issn>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <!-- Library of Congress Control Number, LOC Nummer -->
                <xsl:for-each select="//marc:datafield[@tag='010']/marc:subfield[@code='a']">
                    <bibo:lccn><xsl:value-of select="normalize-space(./text())" /></bibo:lccn>
                </xsl:for-each>
                <!-- International Standard Book Number ISBN -->
                <xsl:for-each select="//marc:datafield[@tag='020']/marc:subfield[@code='a']">
                    <bibo:isbn><xsl:value-of select="normalize-space(./text())" /></bibo:isbn>
                </xsl:for-each>

                <!-- Relationen -->
                <!-- ********** -->
                <xsl:for-each select="//marc:datafield[matches(@tag,'^(78[05]|77[03456]|8[012][0-9]|830)$')]/marc:subfield[@code='w']">
                    <xsl:variable name="curi">
                        <xsl:text>http://hub.culturegraph.org/resource/</xsl:text>
                    </xsl:variable>
                    <xsl:variable name="isil" select="substring(./text(),1,8)" />
                    <xsl:variable name="id"   select="substring(./text(),9)" />
                    <xsl:variable name="tag" select="../@tag"/>
                    <xsl:variable name="uri">
                        <xsl:choose>
                            <xsl:when test="starts-with($isil,'(DE-605)')">
                                <xsl:value-of select="concat($curi,'HBZ-',replace($id,'HBZ',''))" />
                            </xsl:when>
                            <xsl:when test="starts-with($isil,'(DE-603)')">
                                <xsl:value-of select="concat($curi,'HEB-',replace($id,'HEB',''))" />
                            </xsl:when>
                            <xsl:when test="starts-with(./text(),'(DE-576)')">
                                <xsl:value-of select="concat($curi,'BSZ-',replace($id,'BSZ',''))" />
                            </xsl:when>
                            <xsl:when test="starts-with($isil,'(DE-604)')">
                                <xsl:value-of select="concat($curi,'BVB-',replace($id,'BVB',''))" />
                            </xsl:when>
                            <xsl:when test="starts-with($isil,'(DE-601)')">
                                <xsl:value-of select="concat($curi,'GBV-',replace($id,'GBV',''))" />
                            </xsl:when>
                            <xsl:when test="starts-with($isil,'(DE-600)')">
                                <xsl:value-of select="concat('http://ld.zdb-services.de/resource/',replace($id,'ZDB',''))" />
                            </xsl:when>
                            <xsl:when test="contains(./text(),'OBV')">
                                <xsl:value-of select="OBV" />
                            </xsl:when>
                            <xsl:when test="starts-with(./text(),'(OCoLC)')">
                                <xsl:value-of select="normalize-space(substring(./text(),8))" />
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="$tag = '773' or $tag = '770'">
                            <dct:isPartOf><xsl:value-of select="$uri" /></dct:isPartOf>
                        </xsl:when>
                        <xsl:when test="$tag = '774'">
                            <dct:hasPart><xsl:value-of select="$uri" /></dct:hasPart>
                        </xsl:when>
                        <xsl:when test="$tag = '775'">
                            <dct:hasVersion><xsl:value-of select="$uri" /></dct:hasVersion>
                        </xsl:when>
                        <xsl:when test="$tag = '776'">
                            <dct:isFormatOf><xsl:value-of select="$uri" /></dct:isFormatOf>
                        </xsl:when>
                        <xsl:when test="$tag = '780'">
                            <rdau:P60261><xsl:value-of select="$uri" /></rdau:P60261>
                        </xsl:when>
                        <xsl:when test="$tag = '785'">
                            <rdau:P60278><xsl:value-of select="$uri" /></rdau:P60278>
                        </xsl:when>

                        <!-- 800 - 830 -->
                        <xsl:otherwise>
                            <dct:isPartOf><xsl:value-of select="$uri"/></dct:isPartOf>
                        </xsl:otherwise>

                    </xsl:choose>
                </xsl:for-each>

                <!-- Ausgabebezeichnung -->
                <xsl:for-each select="//marc:datafield[@tag='250']/marc:subfield[@code='a']">
                    <bibo:edition>
                        <xsl:value-of select="normalize-space(.)" />
                    </bibo:edition>
                </xsl:for-each>

                <!-- Umfangsangabe -->
                <xsl:for-each select="//marc:datafield[@tag='300']">
                    <isbd:P1053>
                        <xsl:for-each select="./marc:subfield[@code='a']">
                            <xsl:value-of select="normalize-space(./text())" />
                        </xsl:for-each>
                    </isbd:P1053>
                </xsl:for-each>

                <!-- Differenzierte Angaben zur Quelle: Bandzählung, Heftzählung, Tag, Monat, Jahr -->
                <xsl:for-each select="//marc:datafield[@tag='773']/marc:subfield[@code='g']">
                    <dct:bibliographicCitation>
                        <xsl:value-of select="normalize-space(./text())" />
                    </dct:bibliographicCitation>
                </xsl:for-each>

                <!-- Titel der Überordnung und vorliegende Bandzählung -->
                <xsl:for-each select="//marc:datafield[@tag='490']/marc:subfield[@code='a' and @code='v']">
                    <dct:bibliographicCitation>
                        <xsl:value-of select="concat(normalize-space(./marc:subfield[@code='a']/text()),' ; ',normalize-space(./marc:subfield[@code='v']/text()))" />
                    </dct:bibliographicCitation>
                </xsl:for-each>
            
                <xsl:for-each select="//marc:datafield[@tag='982']/marc:subfield[@code='a']">
                    <frbr:exemplar rdf:resource="{concat($itemBaseUri,replace(./text(),'^\((.+)\).+$','$1'),'/barcode/',replace(./text(),'^\(.+\)(.+)$','$1'))}" />
                </xsl:for-each>
                
            </rdf:Description>
        </rdf:RDF>
    </xsl:template>

</xsl:stylesheet>