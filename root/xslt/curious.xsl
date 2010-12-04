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
  <ul>
  <xsl:for-each select="//tei:list[@type='curious']/tei:item">
    <xsl:sort select='tei:note'/>
      <li style="margin-bottom:3px">
      <xsl:element name="a">
        <xsl:attribute name="href"><xsl:value-of select="catalyst:resolveref(tei:ref/@target)"/></xsl:attribute>
        <xsl:apply-templates select="tei:note"/>
      </xsl:element>
      </li>
  </xsl:for-each>
  </ul>
</xsl:template>

<xsl:template match="text()">
  <xsl:value-of select="catalyst:uml(.)"/>
</xsl:template>

</xsl:stylesheet>
