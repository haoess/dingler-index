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

<xsl:template match="/">
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
      <table>
        <xsl:for-each select='//tei:text[@type="art_undef" or @type="art_patent"]'>
        <tr>
          <td class="right"><xsl:value-of select='tei:front/tei:titlePart[@type="number"]' /></td>
          <td>
            <xsl:element name="a">
              <xsl:attribute name="href"><xsl:value-of select="$base" />article/<xsl:value-of select="$journal" />/<xsl:value-of select="@xml:id" /></xsl:attribute>
              <xsl:value-of select="catalyst:uml(tei:front/tei:titlePart[@type='column'])" />
            </xsl:element>
          </td>
        </tr>
        </xsl:for-each>
      </table>
    </body>
  </html>
</xsl:template>

</xsl:stylesheet>
