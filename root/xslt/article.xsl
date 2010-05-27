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
  <xsl:apply-templates select='//tei:text[@xml:id=$article]'/>
</xsl:template>

<xsl:template match='tei:text'>
  <xsl:apply-templates />
</xsl:template>

<xsl:template match="tei:titlePart">
  <xsl:choose>
    <xsl:when test='@type="main"'><h1><xsl:value-of select='../tei:titlePart[@type="number"]'/>&#160;<xsl:value-of select="catalyst:uml(.)"/></h1></xsl:when>
    <xsl:when test='@type="sub"'><h2><xsl:value-of select="catalyst:uml(.)"/></h2></xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="tei:p">
  <p><xsl:value-of select="catalyst:uml(.)" /></p>
</xsl:template>

<xsl:template match="tei:table">
  <p class="small"><xsl:value-of select="catalyst:uml(.)" /></p>
</xsl:template>

</xsl:stylesheet>
