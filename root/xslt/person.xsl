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
  <xsl:apply-templates select='//tei:person[@xml:id=$person]'/>
</xsl:template>

<xsl:template match='tei:persName'>
  <h1>
    <xsl:value-of select="./tei:roleName"/><xsl:text> </xsl:text>
    <xsl:value-of select="./tei:addName"/><xsl:text> </xsl:text>
    <xsl:value-of select="./tei:forename"/><xsl:text> </xsl:text>
    <xsl:value-of select="./tei:surname"/>
  </h1>
</xsl:template>

<xsl:template match='tei:birth'>
  <p>geboren: <xsl:apply-templates/></p>
</xsl:template>

<xsl:template match='tei:death'>
  <p>gestorben: <xsl:apply-templates/></p>
</xsl:template>

<xsl:template match='tei:date'>
  <xsl:value-of select="@when"/>
</xsl:template>

<xsl:template match='tei:placeName'>
  (<xsl:apply-templates/>)
</xsl:template>

<xsl:template match='tei:occupation'>
  <h2>Tätigkeiten</h2>
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match='tei:occupation/tei:placeName'>
  <br /><xsl:apply-templates/>
</xsl:template>

<xsl:template match='tei:education'>
  <h2>Werdegang</h2>
  <xsl:apply-templates/>
  <xsl:for-each select='./tei:ref'>
    <xsl:if test="position()=1">
      <br/>Quellen:
    </xsl:if>
    <xsl:element name="a">
      <xsl:attribute name="href"><xsl:value-of select='@target'/></xsl:attribute>
      <xsl:value-of select="position()" />
    </xsl:element>
    <xsl:if test="position()!=last()">, </xsl:if>
  </xsl:for-each>
</xsl:template>

<xsl:template match='tei:note'/>
<xsl:template match='tei:floruit'/>

<xsl:template match="text()">
  <xsl:value-of select="catalyst:uml(.)"/>
</xsl:template>

</xsl:stylesheet>
