<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:catalyst="urn:catalyst"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0">

<xsl:output
  method="xml" media-type="text/xml"
  cdata-section-elements="script style"
  indent="yes"
  omit-xml-declaration="yes"
  encoding="utf-8"/>

<xsl:template match="/">
  <!--<xsl:for-each select="//tei:text//tei:titlePart[@type='main']/tei:persName">-->
  <xsl:for-each select="//tei:titlePart[@type='main']/tei:persName">
    <ptr>
      <person><xsl:value-of select="catalyst:idonly(@ref)"/></person>
      <article><xsl:value-of select="ancestor::tei:text[1]/@xml:id"/></article>
    </ptr>
  </xsl:for-each>
  <xsl:for-each select="//tei:div[@type='misc_undef']//tei:head/tei:persName">
    <ptr>
      <person><xsl:value-of select="catalyst:idonly(@ref)"/></person>
      <article><xsl:value-of select="ancestor::tei:div[1]/@xml:id"/></article>
    </ptr>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
