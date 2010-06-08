<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:catalyst="urn:catalyst"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0">

<xsl:output
  method="xml" media-type="text/html"
  cdata-section-elements="script style"
  indent="yes"
  encoding="utf-8"/>

<xsl:template match="/">
  <h2><xsl:value-of select='//tei:titleStmt/tei:title[@type="sub"]'/></h2>
  <table>
    <xsl:for-each select='//tei:text[@type="art_undef" or @type="art_patent" or @type="art_miscellanea"]'>
    <tr>
      <td class="right"><xsl:apply-templates select='tei:front/tei:titlePart[@type="number"]'/></td>
      <td>
        <xsl:choose>
          <xsl:when test='@type="art_undef" or @type="art_patent"'>
            <xsl:element name="a">
              <xsl:attribute name="href"><xsl:value-of select="$base" />article/<xsl:value-of select="$journal" />/<xsl:value-of select="@xml:id" /></xsl:attribute>
              <xsl:apply-templates select='tei:front/tei:titlePart[@type="column"]'/>
            </xsl:element>
          </xsl:when>
          <xsl:when test='@type="art_miscellanea"'>
            <xsl:element name="div">
              <xsl:attribute name="onclick">expand('#<xsl:value-of select="@xml:id" />')</xsl:attribute>
              <xsl:attribute name="class">pointer clickable</xsl:attribute>
              <xsl:apply-templates select='tei:front/tei:titlePart[@type="column"]'/>
            </xsl:element>
            <xsl:element name="ol">
              <xsl:attribute name="style">margin-top:0; display:none</xsl:attribute>
              <xsl:attribute name="id"><xsl:value-of select="@xml:id" /></xsl:attribute>
              <xsl:for-each select="./tei:body/tei:div[@type='misc_undef']">
                <li><xsl:apply-templates select="tei:head"/></li>
              </xsl:for-each>
            </xsl:element>
          </xsl:when>
        </xsl:choose>
      </td>
    </tr>
    </xsl:for-each>
  </table>
</xsl:template>

<xsl:template match='tei:front/tei:titlePart[@type="number"]'>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match='tei:front/tei:titlePart[@type="column"]'>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match='tei:head//tei:note'>
</xsl:template>

<xsl:template match="tei:choice">
  <xsl:choose>
    <xsl:when test="./tei:reg">
      <xsl:element name="span">
        <xsl:attribute name="title">gemeint: <xsl:value-of select="tei:reg"/></xsl:attribute>
        <xsl:attribute name="class">corr</xsl:attribute>
        <xsl:value-of select="tei:orig"/>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="span">
        <xsl:attribute name="title">Original: <xsl:value-of select="tei:orig"/></xsl:attribute>
        <xsl:attribute name="class">corr</xsl:attribute>
        <xsl:value-of select="tei:corr"/>
      </xsl:element>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="text()">
  <xsl:value-of select="catalyst:uml(.)"/>
</xsl:template>

</xsl:stylesheet>
