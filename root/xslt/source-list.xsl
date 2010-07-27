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

<xsl:template match='/'>
  <div class="personlist">
  <xsl:for-each select="//tei:bibl[catalyst:starts-with(tei:title[@level='j' or @level='m'], $letter)]">  
    <xsl:sort select='tei:title[@level="j" or @level="m"]'/>
    <xsl:apply-templates select="tei:title[@level='j' or @level='m']" mode="name"/>
    <div style="margin-left:2em; margin-bottom:1em">
      <xsl:apply-templates/>
    </div>
  </xsl:for-each>
  </div>
</xsl:template>

<xsl:template match='tei:title[@level="j" or @level="m"]' mode="name">
  <h2><xsl:apply-templates/></h2>
</xsl:template>
<xsl:template match="tei:title[@level='j' or @level='m']"/>

<xsl:template match='tei:title[@prev]'/>
<xsl:template match='tei:title[@next]'/>

<xsl:template match='tei:editor'>
  <h3>Herausgeber</h3>
  <ul>
  <xsl:for-each select="./tei:persName">
    <li><xsl:apply-templates select="." mode="name"/></li>
  </xsl:for-each>
  </ul>
</xsl:template>

<xsl:template match='tei:publisher'>
  <h3>Verlag</h3>
  <p><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match='tei:persName' mode="name">
  <xsl:value-of select="./tei:surname"/>
  <xsl:if test="string(./tei:forename)">,</xsl:if>
  <xsl:text> </xsl:text><xsl:value-of select="./tei:addName"/>
  <xsl:text> </xsl:text><xsl:value-of select="./tei:forename"/>
</xsl:template>
<xsl:template match='tei:persName'/>

<xsl:template match='tei:pubPlace'>
  <p>Erscheinungsort: <xsl:apply-templates/></p>
</xsl:template>

<xsl:template match='tei:settlement'>
  <xsl:apply-templates/>,
</xsl:template>

<xsl:template match='tei:country'>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match='tei:date'>
  <p>Zeitraum: <xsl:apply-templates/></p>
</xsl:template>

<xsl:template match='tei:ref[@target="#ZDB-ID"]'>
  <p>
    <xsl:element name="a">
      <xsl:attribute name="target">_blank</xsl:attribute>
      <xsl:attribute name="href">http://dispatch.opac.d-nb.de/DB=1.1/CMD?ACT=SRCHA&amp;IKT=8506&amp;TRM=<xsl:value-of select="."/></xsl:attribute>
      ZDB-ID: <xsl:value-of select="."/>
    </xsl:element>
  </p>
</xsl:template>

<xsl:template match='tei:ref[@target="e-journal"]'>
  <p>
    <xsl:element name="a">
      <xsl:attribute name="target">_blank</xsl:attribute>
      <xsl:attribute name="href"><xsl:value-of select='.'/></xsl:attribute>
      E-Journal
    </xsl:element>
  </p>
</xsl:template>

<xsl:template match='tei:note'/>

<xsl:template match="text()">
  <xsl:value-of select="catalyst:uml(.)"/>
</xsl:template>

</xsl:stylesheet>
