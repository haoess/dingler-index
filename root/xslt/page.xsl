<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:catalyst="urn:catalyst"
  exclude-result-prefixes="catalyst tei"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0">

<xsl:output
  method="html" media-type="text/html"
  cdata-section-elements="script style"
  indent="yes"
  omit-xml-declaration="yes"
  encoding="utf-8"/>

<xsl:template match='tei:TEI'>
  <xsl:apply-templates />
  <xsl:if test='//tei:note[@place="bottom"]'>
    <div class="footnotesep"></div>
    <xsl:apply-templates select='//tei:note[@place="bottom"]' mode="footnotes"/>
  </xsl:if>
</xsl:template>

<xsl:template match='tei:front/tei:pb'></xsl:template>
<xsl:template match='tei:body//tei:note//tei:pb'></xsl:template>
<xsl:template match='tei:body//tei:note//tei:p//tei:pb'></xsl:template>

<xsl:template match='tei:ab'></xsl:template>

<xsl:template match='tei:body//tei:pb'/>

<xsl:template match="tei:titlePart">
  <xsl:choose>
    <xsl:when test='@type="main"'><h1><xsl:if test='../tei:titlePart[@type="number"]'><xsl:apply-templates select='../tei:titlePart[@type="number"]' mode="titlenumber"/>&#160;</xsl:if><xsl:apply-templates/></h1></xsl:when>
    <xsl:when test='@type="sub"'><h2><xsl:apply-templates/></h2></xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match='tei:titlePart[@type="number"]' mode="titlenumber">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="tei:byline">
  <p><xsl:apply-templates/></p>
</xsl:template>

<xsl:template match="tei:note">
  <sup><xsl:value-of select="@n"/></sup>
</xsl:template>

<xsl:template match="tei:note" mode="footnotes">
  <div class="footnote">
    <span class="up"><xsl:value-of select='@n'/></span>
    <xsl:text> </xsl:text>
    <xsl:apply-templates/>
  </div>
</xsl:template>

<xsl:template match='tei:bibl[@type="source"]'>
  <xsl:choose>
    <xsl:when test="string-length(@ref) != 0">
      <xsl:element name="a">
        <xsl:attribute name="href"><xsl:value-of select="./@ref"/></xsl:attribute>
        <xsl:attribute name="class">fn</xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match='tei:div[@type="section"]/tei:bibl'>
  <h3><xsl:apply-templates/></h3>
</xsl:template>

<xsl:template match="tei:p">
  <xsl:element name="p">
    <xsl:attribute name="class">
      <xsl:if test="contains(@rendition,'#small')">small</xsl:if>
      <xsl:if test="not(contains(@rendition,'#no_indent')) and not(contains(@rendition,'#center')) and not(contains(@rendition,'#right'))">indent</xsl:if>
      <xsl:if test="contains(@rendition,'#center')">center</xsl:if>
      <xsl:if test="contains(@rendition,'#right')">right</xsl:if>
    </xsl:attribute>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="tei:head">
  <h2><xsl:apply-templates/></h2>
</xsl:template>

<xsl:template match="tei:list">
  <ul style="list-style-type:none">
  <xsl:for-each select="tei:item">
    <li><xsl:apply-templates/></li>
  </xsl:for-each>
  </ul>
</xsl:template>

<xsl:template match="tei:listBibl">
  <ul style="list-style-type:circle">
  <xsl:for-each select="tei:bibl">
    <li><xsl:apply-templates/></li>
  </xsl:for-each>
  </ul>
</xsl:template>

<xsl:template match="tei:persName">
  <xsl:element name="span">
    <xsl:choose>
      <xsl:when test="string-length(catalyst:personref(./@ref)) > 4 and not(./@type)">
        <xsl:attribute name="class">person</xsl:attribute>
        <xsl:attribute name="onclick">showperson('<xsl:value-of select="catalyst:personref(./@ref)" />', ''); return false;</xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="class">person</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="tei:ref">
  <xsl:choose>
    <xsl:when test="@target and starts-with(@target, '#tab')">
      <xsl:element name="a">
        <xsl:attribute name="onclick">showtab('<xsl:value-of select="$base"/><xsl:value-of select="$journal"/>/image_markup/<xsl:value-of select="substring-after(@target, '#')"/>.html'); return false;</xsl:attribute>
        <xsl:attribute name="class">pointer</xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="@target and starts-with(@target, 'image_markup/tab')">
      <xsl:element name="a">
        <xsl:attribute name="onclick">showfigure('http://dingler.culture.hu-berlin.de/dingler_static/<xsl:value-of select="$journal"/>/figures/<xsl:value-of select="substring-after(@target, '#')"/>.jpg'); return false;</xsl:attribute>
        <xsl:attribute name="class">pointer</xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="@target and starts-with(@target, '../pj')">
      <xsl:element name="a">
        <xsl:attribute name="href"><xsl:value-of select="catalyst:resolveref(@target)"/></xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="@target and starts-with(@target, '#ar')">
      <xsl:element name="a">
      <xsl:attribute name="href"><xsl:value-of select="catalyst:resolveref(@target)"/></xsl:attribute>
      <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="tei:hi[contains(@rendition, '#wide')]">
  <span class="wide"><xsl:apply-templates/></span>
</xsl:template>

<xsl:template match="tei:hi[contains(@rendition, '#roman')]">
  <span class="roman"><xsl:apply-templates/></span>
</xsl:template>

<xsl:template match="tei:hi[contains(@rendition, '#superscript')]">
  <sup><xsl:apply-templates/></sup>
</xsl:template>

<xsl:template match="tei:formula">
  <div class="center">
  <xsl:element name="img">
    <xsl:attribute name="src"><xsl:value-of select="$journal"/>/<xsl:value-of select="substring-before(tei:graphic/@url, '/')"/>/<xsl:value-of select="substring-after(tei:graphic/@url, '/')"/>.png</xsl:attribute>
  </xsl:element>
  </div>
</xsl:template>

<xsl:template match="tei:figure">
  <!-- TODO: apply this change to {preface,misc,register}.xsl -->
  <xsl:choose>
    <xsl:when test="./tei:p">
      <span style="float:left; margin:10px 10px 10px 0">
      <xsl:element name="img">
        <xsl:attribute name="src">http://dingler.culture.hu-berlin.de/dingler_static/<xsl:value-of select="$journal"/>/<xsl:value-of select="./tei:graphic/@url"/>.png</xsl:attribute>
        <xsl:attribute name="alt"><xsl:apply-templates select="./tei:figDesc"/></xsl:attribute>
        <xsl:attribute name="title"><xsl:apply-templates select="./tei:figDesc"/></xsl:attribute>
        <xsl:attribute name="class">figure</xsl:attribute>
      </xsl:element>
      </span>
    </xsl:when>
    <xsl:otherwise>
      <div class="center small" style="margin:10px 0">
        <xsl:element name="img">
          <xsl:attribute name="src">http://dingler.culture.hu-berlin.de/dingler_static/<xsl:value-of select="$journal"/>/<xsl:value-of select="./tei:graphic/@url"/>.png</xsl:attribute>
          <xsl:attribute name="alt"><xsl:apply-templates select="./tei:figDesc"/></xsl:attribute>
          <xsl:attribute name="title"><xsl:apply-templates select="./tei:figDesc"/></xsl:attribute>
          <xsl:attribute name="class">figure</xsl:attribute>
        </xsl:element>
      </div>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!--<g ref="#z0001"/>-->
<xsl:template match="tei:g">
  <xsl:element name="img">
    <xsl:attribute name="src"><xsl:value-of select="catalyst:ext_ent(substring-after(@ref, '#'))"/></xsl:attribute>
    <xsl:attribute name="style">float:left</xsl:attribute>
  </xsl:element>
</xsl:template>

<xsl:template match="tei:lb"><br /></xsl:template>

<!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
<!-- tables -->

<xsl:template match="tei:table">
  <table style="margin-left:auto; margin-right:auto" class="middlealign">
  <xsl:apply-templates select="tei:row"/>
  </table>
</xsl:template>

<xsl:template match="tei:row">
  <tr>
    <xsl:apply-templates select="tei:cell"/>
  </tr>
</xsl:template>

<xsl:template match="tei:cell">
  <xsl:choose>
    <xsl:when test="parent::tei:row[@role='label']">
      <xsl:element name="th">
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="td">
        <xsl:if test="@cols">
          <xsl:attribute name="colspan"><xsl:value-of select="@cols"/></xsl:attribute>
        </xsl:if>
        <xsl:attribute name="class"><xsl:value-of select="catalyst:rendition(@rendition)"/></xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->

<xsl:template match="tei:choice">
  <xsl:choose>
    <xsl:when test="./tei:reg">
      <xsl:element name="span">
        <xsl:attribute name="title">gemeint: <xsl:value-of select="tei:reg"/></xsl:attribute>
        <xsl:attribute name="class">corr</xsl:attribute>
        <xsl:apply-templates select="tei:orig"/>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="span">
        <xsl:attribute name="title">Original: <xsl:value-of select="tei:orig"/></xsl:attribute>
        <xsl:attribute name="class">corr</xsl:attribute>
        <xsl:apply-templates select="tei:corr"/>
      </xsl:element>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="tei:q">
  <q><xsl:apply-templates/></q>
</xsl:template>

<xsl:template match="tei:unclear"></xsl:template>
<xsl:template match="tei:add"></xsl:template>

<xsl:template match="text()">
  <xsl:value-of select="catalyst:uml(.)"/>
</xsl:template>

</xsl:stylesheet>
