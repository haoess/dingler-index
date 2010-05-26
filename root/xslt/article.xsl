<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:catalyst="urn:catalyst"
  xmlns="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0">

<xsl:output
  method="xml" media-type="text/html" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
  doctype-system="DTD/xhtml1-strict.dtd"
  cdata-section-elements="script style"
  indent="yes"
  encoding="utf-8"/>

<xsl:template match='/'>
  <xsl:apply-templates select='//tei:text[@xml:id=$article]'/>
</xsl:template>

<xsl:template match='tei:text'>
  <html xmlns="http://www.w3.org/1999/xhtml">
    <head>
      <xsl:element name="base">
        <xsl:attribute name="href"><xsl:value-of select="$base" /></xsl:attribute>
      </xsl:element>
      <style type="text/css">
        * { font-family:"Arial" }
        td.right { text-align:right }
      </style>
    </head>
    <body>
       <xsl:apply-templates />
    </body>
  </html>
</xsl:template>

<xsl:template match="tei:titlePart">
  <xsl:choose>
    <xsl:when test='@type="main"'><h1><xsl:value-of select='../tei:titlePart[@type="number"]'/><xsl:value-of select="catalyst:uml(.)"/></h1></xsl:when>
    <xsl:when test='@type="sub"'><h2><xsl:value-of select="catalyst:uml(.)"/></h2></xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="tei:p">
  <p><xsl:value-of select="catalyst:uml(.)" /></p>
</xsl:template>

</xsl:stylesheet>
