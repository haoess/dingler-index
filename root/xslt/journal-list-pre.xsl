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
  <journal>
    <file><xsl:value-of select="$journal"/></file>
    <volume><xsl:value-of select='//tei:imprint/tei:biblScope'/></volume>
    <year><xsl:value-of select='//tei:imprint/tei:date'/></year>
    <faclink><xsl:value-of select='catalyst:faclink(//tei:sourceDesc//tei:idno)'/></faclink>
  </journal>
</xsl:template>

</xsl:stylesheet>
