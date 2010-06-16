<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:catalyst="urn:catalyst"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0">

<xsl:output
  method="xml" media-type="text/xml"
  cdata-section-elements="script style"
  indent="yes"
  omit-xml-declaration="yes"
  encoding="utf-8"/>

<xsl:template match="/">
  <journal>
    <file><xsl:value-of select="$journal"/></file>
    <volume><xsl:value-of select='//tei:imprint/tei:biblScope'/></volume>
    <year><xsl:value-of select='//tei:imprint/tei:date'/></year>
    <faclink><xsl:value-of select='catalyst:faclink(//tei:sourceDesc//tei:idno)'/></faclink>
    <articles>
    <xsl:for-each select='//tei:text[@type="art_undef" or @type="art_patent" or @type="art_misc"]'>
      <article>
        <number><xsl:value-of select='tei:front/tei:titlePart[@type="number"]'/></number>
        <id><xsl:value-of select="@xml:id"/></id>
        <title><xsl:value-of select="catalyst:uml(tei:front/tei:titlePart[@type='column'])"/></title>
        <pagestart>
          <xsl:choose>
            <xsl:when test="tei:front/tei:pb[1]">
              <xsl:value-of select="tei:front/tei:pb[1]/@n"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="preceding::tei:pb[1]/@n" />
            </xsl:otherwise>
          </xsl:choose>
        </pagestart>
        <pageend><xsl:value-of select="following::*/preceding::tei:pb[1]/@n"/></pageend>
        <facsimile>
          <xsl:choose>
            <xsl:when test="tei:front/tei:pb[1]">
              <xsl:value-of select="catalyst:faclink(tei:front/tei:pb[1]/@facs)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="catalyst:faclink(preceding::tei:pb[1]/@facs)" />
            </xsl:otherwise>
          </xsl:choose>
        </facsimile>
      </article>
    </xsl:for-each>
    </articles>
  </journal>
</xsl:template>

</xsl:stylesheet>
