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
  omit-xml-declaration="yes"
  encoding="utf-8"/>

<xsl:template match="/">
  <xsl:for-each select='//journal'>
    <tr>
      <td class="right">
        <xsl:element name="a">
          <xsl:attribute name="href"><xsl:select value-of="$base"/>/journal/<xsl:value-of select="./file"/></xsl:attribute>
          Band <xsl:value-of select='./volume'/>
        </xsl:element>
      </td>
      <td>(<xsl:value-of select='./year'/>)</td>
      <td style="padding-left:20px">
        <xsl:element name="a">
          <xsl:attribute name="href"><xsl:value-of select='./faclink'/></xsl:attribute>
          &#x2192; Faksimile
        </xsl:element>
      </td>
    </tr>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
