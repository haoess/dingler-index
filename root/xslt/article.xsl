<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:catalyst="urn:catalyst"
  exclude-result-prefixes="catalyst tei"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0">

<xsl:output
  method="xml" media-type="text/html"
  cdata-section-elements="script style"
  indent="yes"
  omit-xml-declaration="yes"
  encoding="utf-8"/>

<xsl:template match='/'>
  <xsl:apply-templates select='//tei:text[@xml:id=$article]'/>
  <xsl:apply-templates select='//tei:note' mode="notecontent"/>
</xsl:template>

<xsl:template match='tei:text'>
  <xsl:apply-templates />
</xsl:template>

<xsl:template match='tei:front/tei:pb'>
</xsl:template>

<xsl:template match='tei:body//tei:pb'>
  <xsl:element name="span">
    <xsl:attribute name="id">pb<xsl:value-of select="@n"/></xsl:attribute>
    <xsl:element name="a">
      <xsl:attribute name="href"><xsl:value-of select="catalyst:faclink(@facs)"/></xsl:attribute>
      <xsl:attribute name="target">_blank</xsl:attribute>
      [S. <xsl:value-of select="@n"/>]
    </xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template match="tei:titlePart">
  <xsl:choose>
    <xsl:when test='@type="main"'><h1><xsl:apply-templates select='../tei:titlePart[@type="number"]' mode="titlenumber"/>&#160;<xsl:apply-templates/></h1></xsl:when>
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
  <sup class="fnref">
    <xsl:element name="span">
      <xsl:attribute name="idref"><xsl:value-of select="./tei:pb/@xml:id"/></xsl:attribute>
      <xsl:value-of select="@n"/>
    </xsl:element>
  </sup>
</xsl:template>

<xsl:template match="tei:note" mode="notecontent">
  <xsl:element name="div">
    <xsl:attribute name="class">fn</xsl:attribute>
    <xsl:attribute name="id"><xsl:value-of select="./tei:pb/@xml:id"/></xsl:attribute>
    <xsl:apply-templates/>
  </xsl:element>
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

<xsl:template match="tei:p">
  <xsl:element name="p">
    <xsl:attribute name="class">
      <xsl:if test="contains(@rendition,'#small')">small</xsl:if>
      <xsl:if test="not(contains(@rendition,'#no_indent')) and not(contains(@rendition,'#center'))">indent</xsl:if>
      <xsl:if test="contains(@rendition,'#center')">center</xsl:if>
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

<xsl:template match="tei:persName">
  <xsl:element name="span">
    <xsl:attribute name="class">person</xsl:attribute>
    <xsl:if test="string-length(catalyst:personref(./@ref)) > 0">
      <xsl:attribute name="onclick">showperson('<xsl:value-of select="catalyst:personref(./@ref)" />', '<xsl:value-of select="$article"/>'); return false;</xsl:attribute>
    </xsl:if>
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
        <xsl:attribute name="onclick">showtab('<xsl:value-of select="$base"/><xsl:value-of select="$journal"/>/<xsl:value-of select="substring-before(@target, '.xml')"/>.html#Ann_<xsl:value-of select="substring-after(@target, '#')"/>'); return false;</xsl:attribute>
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
  <xsl:element name="img">
    <xsl:attribute name="src"><xsl:value-of select="$journal"/>/<xsl:value-of select="substring-before(tei:graphic/@url, '/')"/>/<xsl:value-of select="substring-after(tei:graphic/@url, '/')"/>.png</xsl:attribute>
  </xsl:element>
</xsl:template>

<xsl:template match="tei:figure">
  <div class="center small" style="margin:10px 0">
    <xsl:element name="img">
      <xsl:attribute name="src">http://www.culture.hu-berlin.de/dingler_static/<xsl:value-of select="$journal"/>/<xsl:value-of select="./tei:graphic/@url"/>.png</xsl:attribute>
      <xsl:attribute name="alt"><xsl:apply-templates select="./tei:figDesc"/></xsl:attribute>
      <xsl:attribute name="title"><xsl:apply-templates select="./tei:figDesc"/></xsl:attribute>
      <xsl:attribute name="class">figure</xsl:attribute>
    </xsl:element>
    <br />
    <xsl:apply-templates select="./tei:figDesc"/>
  </div>
</xsl:template>

<!--<g ref="#z0001"/>-->
<xsl:template match="tei:g">
  <xsl:element name="img">
    <xsl:attribute name="src"><xsl:value-of select="catalyst:ext_ent(substring-after(@ref, '#'))"/></xsl:attribute>
    <xsl:attribute name="style">float:left</xsl:attribute>
  </xsl:element>
</xsl:template>

<xsl:template match="tei:lb"><br /></xsl:template>

<xsl:template match="tei:table">
  <table style="margin-left:auto; margin-right:auto" class="middlealign">
  <xsl:for-each select="tei:row">
    <tr>
    <xsl:for-each select="tei:cell">
      <xsl:choose>
        <xsl:when test="../@role='label'">
          <xsl:element name="th">
            <xsl:apply-templates/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:element name="td">
            <xsl:if test="@cols">
              <xsl:attribute name="colspan"><xsl:value-of select="@cols"/></xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
          </xsl:element>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    </tr>
  </xsl:for-each>
  </table>
</xsl:template>

<xsl:template match="tei:choice">
  <xsl:choose>
    <xsl:when test="./tei:reg">
      <xsl:element name="span">
        <xsl:attribute name="title">gemeint: <xsl:value-of select="tei:reg"/></xsl:attribute>
        <xsl:attribute name="class">corr</xsl:attribute>
        <xsl:value-of select="tei:orig"/>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:element name="span">
        <xsl:attribute name="title">Original: <xsl:value-of select="tei:orig"/></xsl:attribute>
        <xsl:attribute name="class">corr</xsl:attribute>
        <xsl:value-of select="tei:corr"/>
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
