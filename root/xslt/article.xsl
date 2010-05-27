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
    <xsl:when test='@type="main"'><h1><xsl:value-of select='../tei:titlePart[@type="number"]'/>&#160;<xsl:apply-templates/></h1></xsl:when>
    <xsl:when test='@type="sub"'><h2><xsl:apply-templates/></h2></xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="tei:note">
  <sup>
    <xsl:text disable-output-escaping="yes">&lt;a class="fn" title=&quot;</xsl:text>
    <xsl:value-of select="catalyst:uml(.)"/>
    <xsl:text disable-output-escaping="yes">&quot;&gt;</xsl:text>
    <xsl:value-of select="@n"/>
    <xsl:text disable-output-escaping="yes">&lt;/a&gt;</xsl:text>
  </sup>
</xsl:template>

<xsl:template match="tei:p">
  <p><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="tei:table">
  <p class="small"><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="tei:head">
  <h2><xsl:apply-templates/></h2>
</xsl:template>

<xsl:template match="tei:list">
  <ul>
  <xsl:for-each select="tei:item">
    <li><xsl:apply-templates/></li>
  </xsl:for-each>
  </ul>
</xsl:template>

<xsl:template match="text()">
  <xsl:value-of select="catalyst:uml(.)"/>
</xsl:template>

</xsl:stylesheet>
