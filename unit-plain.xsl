<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0">

<xsl:output
  method="text" media-type="text/plain"
  encoding="utf-8"/>

<xsl:template match='/'>
  <xsl:apply-templates select='//*[@xml:id=$id]'/>
</xsl:template>

<xsl:template match='tei:front'>
  <xsl:apply-templates/>
  <xsl:text>&#xa;&#xa;</xsl:text>
</xsl:template>

<xsl:template match='tei:titlePart'>
  <xsl:apply-templates/>
  <xsl:text>&#xa;&#xa;</xsl:text>
</xsl:template>

<xsl:template match='tei:head'>
  <xsl:apply-templates/>
  <xsl:text>&#xa;&#xa;</xsl:text>
</xsl:template>

<xsl:template match='tei:p'>
  <xsl:apply-templates/>
  <xsl:text>&#xa;&#xa;</xsl:text>
</xsl:template>

<xsl:template match='tei:div[@type="section"]'>
  <xsl:apply-templates/>
  <xsl:text>&#xa;&#xa;</xsl:text>
</xsl:template>

<xsl:template match='tei:item'>
  <xsl:apply-templates/>
  <xsl:text>&#xa;&#xa;</xsl:text>
</xsl:template>

<xsl:template match="tei:lb">
  <xsl:text>&#xa;</xsl:text>
  <xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>
