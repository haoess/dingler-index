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
    <volume><xsl:apply-templates select='//tei:imprint/tei:biblScope'/></volume>
    <year><xsl:apply-templates select='//tei:imprint/tei:date'/></year>
    <faclink><xsl:value-of select='catalyst:faclink(//tei:sourceDesc//tei:idno)'/></faclink>
    <articles>
    <xsl:for-each select='//tei:text[@type="art_undef" or @type="art_patent" or @type="art_misc"]'>
      <article>
        <number><xsl:apply-templates select='tei:front/tei:titlePart[@type="number"]'/></number>
        <id><xsl:value-of select="@xml:id"/></id>
        <title><xsl:apply-templates select="tei:front/tei:titlePart[@type='column']"/></title>
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
        <figures>
          <xsl:for-each select='.//tei:ref[starts-with(@target, "#tab")]'>
            <figure>http://www.polytechnischesjournal.de/fileadmin/data/<xsl:value-of select="//tei:biblStruct/tei:monogr/tei:idno"/>/editura/image_markup/<xsl:value-of select="substring-after(@target, '#')"/>_wv_<xsl:value-of select="substring-after(@target, '#')"/>.jpg</figure>
          </xsl:for-each>
        </figures>
      </article>
    </xsl:for-each>
    </articles>
  </journal>
</xsl:template>

<xsl:template match="tei:choice">
  <xsl:choose>
    <xsl:when test="./tei:reg">
      <xsl:apply-templates select="tei:orig"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates select="tei:corr"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="text()">
  <xsl:value-of select="catalyst:uml(.)"/>
</xsl:template>

</xsl:stylesheet>
