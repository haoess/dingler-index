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
  <xsl:for-each select="//tei:person[catalyst:starts-with(tei:persName/tei:surname, $letter)]">
    <xsl:sort select="tei:persName/tei:surname"/>
    <xsl:sort select="tei:persName/tei:forename"/>
    <xsl:apply-templates select="tei:persName" mode="name"/>
    <div style="margin-left:2em; margin-bottom:1em">
      <xsl:apply-templates/>
      <xsl:value-of select="catalyst:personarticles(@xml:id)" disable-output-escaping="yes"/>
    </div>
  </xsl:for-each>
  </div>
</xsl:template>

<xsl:template match='tei:persName' mode="name">
  <h2>
    <xsl:value-of select="./tei:surname"/>
    <xsl:if test="string(./tei:forename)">,</xsl:if>
    <xsl:text> </xsl:text><xsl:value-of select="./tei:addName"/>
    <xsl:text> </xsl:text><xsl:value-of select="./tei:forename"/>
  </h2>
</xsl:template>
<xsl:template match='tei:persName'/>

<xsl:template match='tei:birth'>
  <p>
    *
    <xsl:apply-templates select='tei:date'/>
    <xsl:if test='tei:placeName'> in <xsl:apply-templates select='tei:placeName'/></xsl:if>
  </p>
</xsl:template>

<xsl:template match='tei:death'>
  <p>
    †
    <xsl:apply-templates select='tei:date'/>
    <xsl:if test='tei:placeName'> in <xsl:apply-templates select='tei:placeName'/></xsl:if>
  </p>
</xsl:template>

<xsl:template match='tei:date'>
  <xsl:value-of select="catalyst:persondate(@when)"/>
</xsl:template>

<xsl:template match='tei:placeName'>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match='tei:occupation'>
  <h3>Tätigkeiten</h3>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match='tei:occupation/tei:placeName'>
  <br /><xsl:apply-templates/>
</xsl:template>

<xsl:template match='tei:education'>
  <h3>Werdegang</h3>
  <xsl:apply-templates/>
  <xsl:for-each select='./tei:ref'>
    <xsl:if test="position()=1">
      <br /><br />Quellen:
    </xsl:if>
    <xsl:element name="a">
      <xsl:attribute name="href"><xsl:value-of select='@target'/></xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
    <xsl:if test="position()!=last()">, </xsl:if>
  </xsl:for-each>
</xsl:template>

<xsl:template match='tei:ref'/>
<xsl:template match='tei:note'/>
<xsl:template match='tei:floruit'/>

<xsl:template match="text()">
  <xsl:value-of select="catalyst:uml(.)"/>
</xsl:template>

</xsl:stylesheet>