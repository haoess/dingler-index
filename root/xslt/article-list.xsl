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
  <xsl:apply-templates select='//tei:titlePage[@type="volume"]'/>
  <table>
    <xsl:if test='//tei:div[@type="preface"]'>
      <tr>
        <td></td>
        <td>
          <xsl:element name="a">
            <xsl:attribute name="href"><xsl:value-of select="$base" />journal/preface/<xsl:value-of select="$journal" /></xsl:attribute>
            <xsl:choose>
              <xsl:when test='//tei:div[@type="preface"]/tei:head'>
                <xsl:value-of select='//tei:div[@type="preface"]/tei:head'/>
              </xsl:when>
              <xsl:otherwise>
                [Vorwort]
              </xsl:otherwise>
            </xsl:choose>
          </xsl:element>
        </td>
      </tr>
    </xsl:if>
    <xsl:for-each select='//tei:text[@type="art_undef" or @type="art_patent" or @type="art_miscellanea" or @type="art_patents"]'>
    <tr>
      <td class="right"><xsl:apply-templates select='tei:front/tei:titlePart[@type="number"]'/></td>
      <td>
        <xsl:choose>
          <xsl:when test='@type="art_undef" or @type="art_patent" or @type="art_patents"'>
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
                <li>
                  <xsl:element name="a">
                    <xsl:attribute name="href"><xsl:value-of select="$base" />article/<xsl:value-of select="$journal" />/<xsl:value-of select="@xml:id" /></xsl:attribute>
                    <xsl:apply-templates select="tei:head"/>
                  </xsl:element>
                </li>
              </xsl:for-each>
            </xsl:element>
          </xsl:when>
        </xsl:choose>
      </td>
    </tr>
    </xsl:for-each>
  </table>
</xsl:template>

<xsl:template match='//tei:titlePage[@type="volume"]'>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match='tei:titlePart[@type="main"]'>
  <h1><xsl:apply-templates/></h1>
</xsl:template>

<xsl:template match='tei:titlePart[@type="sub"]'>
  <p><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match='tei:titlePart[@type="volume"]'>
  <h2><xsl:apply-templates/></h2>
</xsl:template>

<xsl:template match='tei:titlePart[@type="year"]'>
  <h2><xsl:apply-templates/></h2>
</xsl:template>

<xsl:template match='tei:docImprint'>
  <p><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match='//tei:docTitle//tei:lb'>
  <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match='//tei:docImprint//tei:lb'>
  <br />
</xsl:template>

<xsl:template match="tei:hi[contains(@rendition, '#wide')]">
  <span class="wide"><xsl:apply-templates/></span>
</xsl:template>

<xsl:template match="tei:hi[contains(@rendition, '#roman')]">
  <span class="roman"><xsl:apply-templates/></span>
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
