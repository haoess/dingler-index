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
  <xsl:apply-templates select='//*[@xml:id=$id]'/>
  <xsl:apply-templates select='//*[@xml:id=$id]//tei:note' mode="notecontent"/>
</xsl:template>

<xsl:template match='tei:text'>
  <xsl:apply-templates />
</xsl:template>

<xsl:template match='tei:front/tei:pb'></xsl:template>
<xsl:template match='tei:body//tei:note//tei:pb'></xsl:template>
<xsl:template match='tei:body//tei:note//tei:p//tei:pb'></xsl:template>

<xsl:template match='tei:ab'></xsl:template>

<xsl:template match='tei:body//tei:pb'>
  <xsl:element name="span">
    <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
    <xsl:attribute name="class">pagebreak</xsl:attribute>
    <xsl:text> |</xsl:text>
    <xsl:element name="a">
      <xsl:attribute name="href"><xsl:value-of select="catalyst:faclink(@facs)"/></xsl:attribute>
      <xsl:attribute name="target">_blank</xsl:attribute>
      <xsl:value-of select="@n"/>
    </xsl:element>
    <xsl:text>| </xsl:text>
  </xsl:element>
  <xsl:if test="not(ancestor::tei:note)">
    <span class="left-facs">
      <xsl:element name="a">
        <xsl:attribute name="href"><xsl:value-of select="catalyst:faclink(@facs)"/></xsl:attribute>
        <xsl:attribute name="target">_blank</xsl:attribute>
        <xsl:element name="img">
          <xsl:attribute name="src"><xsl:value-of select="catalyst:facthumb(@facs)"/></xsl:attribute>
        </xsl:element>
      </xsl:element>
    </span>
  </xsl:if>
</xsl:template>

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
  <xsl:choose>
    <xsl:when test="@n">
      <sup class="fnref">
        <xsl:element name="span">
          <xsl:attribute name="idref"><xsl:value-of select="./tei:pb/@xml:id"/></xsl:attribute>
          <xsl:value-of select="@n"/>
        </xsl:element>
      </sup>
    </xsl:when>
    <xsl:when test="@type='digital_edition'">
      <span style="font-size:.8em;color:#aaa"> [<xsl:value-of select="."/>] </span>
    </xsl:when>
  </xsl:choose>
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

<xsl:template match='tei:div[@type="section"]/tei:bibl'>
  <h3><xsl:apply-templates/></h3>
</xsl:template>

<xsl:template match="tei:p">
  <xsl:element name="p">
    <xsl:if test="@rendition">
      <xsl:call-template name="applyRendition"/>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="tei:head">
  <h2>
    <xsl:if test="@rendition">
      <xsl:call-template name="applyRendition"/>
    </xsl:if>
    <xsl:apply-templates/>
  </h2>
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
        <xsl:attribute name="class">person pointer</xsl:attribute>
        <xsl:attribute name="onclick">showperson('<xsl:value-of select="catalyst:personref(./@ref)" />', '<xsl:value-of select="$id"/>'); return false;</xsl:attribute>
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
    <xsl:when test="@target and contains(@target, '#tab')">
      <xsl:element name="a">
        <xsl:attribute name="onclick">showtab('<xsl:value-of select="$base"/><xsl:value-of select="catalyst:resolvetab(@target)"/>.html'); return false;</xsl:attribute>
        <xsl:attribute name="class">pointer</xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:when test="@target and contains(@target, 'image_markup/tab')">
      <xsl:element name="a">
        <xsl:attribute name="onclick">showfigure('http://dingler.culture.hu-berlin.de/dingler_static/<xsl:value-of select="catalyst:resolvefig(@target)"/>.jpg'); return false;</xsl:attribute>
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
    <xsl:when test="@target and starts-with(@target, '#tx')">
<!--  <xsl:element name="a">
        <xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>-->
      <xsl:element name="a">
        <xsl:attribute name="onclick">showfigure('http://dingler.culture.hu-berlin.de/dingler_static/<xsl:value-of select="catalyst:resolvetx(@target)"/>.png', 1); return false;</xsl:attribute>
        <xsl:attribute name="class">pointer</xsl:attribute>
        <xsl:apply-templates/>
      </xsl:element>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="tei:hi">
  <xsl:element name="span">
    <xsl:if test="@rendition">
      <xsl:call-template name="applyRendition"/>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="tei:formula">
  <span class="formula">
    <xsl:choose>
      <xsl:when test="text()!=''">
        <xsl:element name="img">
          <xsl:attribute name="style">vertical-align:middle</xsl:attribute>
          <xsl:choose>
            <xsl:when test="@rendition">
              <xsl:call-template name="applyRendition"/>
              <xsl:attribute name="src">
                <xsl:text>http://dinglr.de/formula/</xsl:text><xsl:value-of select="catalyst:urlencode(.)"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="src">
                <xsl:text>http://dinglr.de/formula/</xsl:text><xsl:value-of select="catalyst:urlencode(.)"/>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <span style="color:#666">[Formelnotation ist momentan in Bearbeitung]</span>
      </xsl:otherwise>
    </xsl:choose>
  </span>
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
          <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
        </xsl:element>
      </span>
    </xsl:when>
    <xsl:otherwise>
      <div class="center small" style="margin:10px 0">
        <xsl:element name="img">
          <xsl:attribute name="src">http://dingler.culture.hu-berlin.de/dingler_static/<xsl:value-of select="$journal"/>/<xsl:value-of select="./tei:graphic/@url"/>.png</xsl:attribute>
          <xsl:attribute name="alt"><xsl:apply-templates select="./tei:figDesc"/></xsl:attribute>
          <xsl:attribute name="title"><xsl:apply-templates select="./tei:figDesc"/></xsl:attribute>
          <xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
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
    <!--<xsl:attribute name="style">float:left</xsl:attribute>-->
    <xsl:attribute name="class">dingler-g</xsl:attribute>
  </xsl:element>
</xsl:template>

<xsl:template match="tei:lb"><br /></xsl:template>
<xsl:template match="tei:cb"> </xsl:template>

<!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
<!-- tables -->

<xsl:template match="tei:table">
  <xsl:element name="table">
    <xsl:attribute name="class">
      middlealign pjtable
      <xsl:if test="@rend='boxed'">
        boxed
      </xsl:if>
    </xsl:attribute>
    <xsl:apply-templates select="tei:row"/>
  </xsl:element>
</xsl:template>

<xsl:template match="tei:row">
  <tr>
    <xsl:apply-templates select="tei:cell"/>
  </tr>
</xsl:template>

<xsl:template match="tei:cell">
  <xsl:element name="td">
    <xsl:if test="@cols">
      <xsl:attribute name="colspan"><xsl:value-of select="@cols"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="@rows">
      <xsl:attribute name="rowspan"><xsl:value-of select="@rows"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="@rendition">
      <xsl:call-template name="applyRendition"/>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<!--
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
-->

<!-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ -->
<!-- renditions -->
<xsl:template name="applyRendition">
  <xsl:attribute name="class">
    <xsl:choose>
      <xsl:when test="@rendition=''"/>
      <xsl:when test="contains(normalize-space(@rendition),' ')">
        <xsl:call-template name="splitRendition">
          <xsl:with-param name="value">
            <xsl:value-of select="normalize-space(@rendition)"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="findRendition">
          <xsl:with-param name="value">
            <xsl:value-of select="@rendition"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:attribute>
</xsl:template>

<xsl:template name="splitRendition">
  <xsl:param name="value"/>
  <xsl:choose>
    <xsl:when test="$value=''"/>
    <xsl:when test="contains($value,' ')">
      <xsl:call-template name="findRendition">
        <xsl:with-param name="value">
          <xsl:value-of select="substring-before($value,' ')"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="splitRendition">
        <xsl:with-param name="value">
          <xsl:value-of select="substring-after($value,' ')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="findRendition">
        <xsl:with-param name="value">
          <xsl:value-of select="$value"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="findRendition">
  <xsl:param name="value"/>
  <xsl:choose>
    <xsl:when test="starts-with($value,'#')">
      <xsl:text>rend-</xsl:text><xsl:value-of select="substring-after($value,'#')"/>
      <xsl:text> </xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:for-each select="document($value)">
        <xsl:apply-templates select="@xml:id"/>
        <xsl:text> </xsl:text>
      </xsl:for-each>
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

<xsl:template match="tei:unclear">
  <xsl:choose>
    <xsl:when test="@reason='illegible'">
      <xsl:choose>
        <xsl:when test="not(node())">
          <span style="color:#aaa;font-size:.8em">[Stelle unleserlich]</span>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:when test="@reason='misprint'">
      <xsl:choose>
        <xsl:when test="not(node())">
          <span style="color:#aaa;font-size:.8em">[Fehldruck]</span>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="tei:gap">
  <xsl:choose>
    <xsl:when test="parent::tei:unclear[@reason='illegible']">
      <span style="color:#aaa;font-size:.8em" title="Stelle unleserlich">[...]</span>
    </xsl:when>
    <xsl:when test="parent::tei:unclear[@reason='misprint']">
      <span style="color:#aaa;font-size:.8em" title="Fehldruck">[...]</span>
    </xsl:when>
  </xsl:choose>
</xsl:template>

<xsl:template match="tei:add"></xsl:template>

<xsl:template match="text()">
  <xsl:value-of select="catalyst:uml(.)"/>
</xsl:template>

</xsl:stylesheet>
