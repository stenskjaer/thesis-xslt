<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0" xmlns:tei="http://www.tei-c.org/ns/1.0">

  <xsl:param name="apploc"><xsl:value-of select="/TEI/teiHeader/encodingDesc/variantEncoding/@location"/></xsl:param>
  <xsl:param name="notesloc"><xsl:value-of select="/TEI/teiHeader/encodingDesc/variantEncoding/@location"/></xsl:param>
  <xsl:variable name="title"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/title"/></xsl:variable>
  <xsl:variable name="author"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/author"/></xsl:variable>
  <xsl:variable name="editor"><xsl:value-of select="/TEI/teiHeader/fileDesc/titleStmt/editor"/></xsl:variable>
  <xsl:param name="targetdirectory">null</xsl:param>
  <!-- get versioning numbers -->
  <xsl:param name="sourceversion"><xsl:value-of select="/TEI/teiHeader/fileDesc/editionStmt/edition/@n"/></xsl:param>

  <!-- this xsltconvnumber should be the same as the git tag, and for any commit past the tag should be the tag name plus '-dev' -->
  <xsl:param name="conversionversion">dev</xsl:param>

  <!-- default is dev; if a unique version number for the print output is desired; it should be passed as a parameter -->

  <!-- combined version number should have mirror syntax of an equation x+y source+conversion -->
  <xsl:variable name="combinedversionnumber"><xsl:value-of select="$sourceversion"/>+<xsl:value-of select="$conversionversion"/></xsl:variable>
  <!-- end versioning numbers -->
  <xsl:variable name="fs"><xsl:value-of select="/TEI/text/body/div/@xml:id"/></xsl:variable>
  <xsl:variable name="name-list-file">../lists/prosopography.xml</xsl:variable>
  <xsl:variable name="work-list-file">../lists/workscited.xml</xsl:variable>

  <xsl:output method="text" indent="no"/>
  <!-- <xsl:strip-space elements="*"/> -->
  <!-- <xsl:template match="text()"> -->
  <!--   <xsl:value-of select="normalize-space(.)"/> -->
  <!-- </xsl:template> -->
  <!-- <xsl:template match="text()"> -->
  <!--     <xsl:value-of select="replace(., '\s+', ' ')"/> -->
  <!-- </xsl:template> -->

  <xsl:template match="/">
    \section*{<xsl:value-of select="$author"/>: <xsl:value-of select="$title"/>}
    \addcontentsline{toc}{section}{<xsl:value-of select="$title"/>}

    Beware! This is a diplomatic transcription, and most likely at an early
    draft state. No effort has been made in normalizing or improving the text.
    It is therefore very likely that the presented text is incomprehensible,
    faulty, and riddled with question marks.
    <xsl:apply-templates select="//body"/>
  </xsl:template>

  <xsl:template match="div//head">\section*{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="div//div">
    \bigskip
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="p">
    <xsl:variable name="pn"><xsl:number level="any" from="tei:text"/></xsl:variable>
    <xsl:text>\pstart</xsl:text>
    <xsl:call-template name="createLabelFromId">
      <xsl:with-param name="labelType">start</xsl:with-param>
    </xsl:call-template>
    <xsl:choose>
      <xsl:when test="@type = 'ratio'">
        <xsl:choose>
          <xsl:when test="not(@n)">
            <xsl:text>\no{1} </xsl:text>
          </xsl:when>
          <xsl:otherwise>\no{1.<xsl:value-of select="@n"/>} </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="@type = 'oppositum'">
        <xsl:choose>
          <xsl:when test="not(@n)">
            <xsl:text>\no{2} </xsl:text>
          </xsl:when>
          <xsl:otherwise>\no{2.<xsl:value-of select="@n"/>} </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="@type = 'determinatio'">
        <xsl:choose>
          <xsl:when test="not(@n)">
            <xsl:text>\no{3} </xsl:text>
          </xsl:when>
          <xsl:otherwise>\no{3.<xsl:value-of select="@n"/>} </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="@type = 'ad_rationes'">
        <xsl:choose>
          <xsl:when test="not(@n)">
            <xsl:text>\no{Ad 1} </xsl:text>
          </xsl:when>
          <xsl:otherwise>\no{Ad 1.<xsl:value-of select="@n"/>} </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates/>
    <xsl:call-template name="createLabelFromId">
      <xsl:with-param name="labelType">end</xsl:with-param>
    </xsl:call-template>
    <xsl:text>\pend</xsl:text>
  </xsl:template>
  <xsl:template match="head">
  </xsl:template>
  <xsl:template match="div">
    \beginnumbering
    <xsl:apply-templates/>
    \endnumbering
  </xsl:template>

  <xsl:template match="unclear">\emph{<xsl:apply-templates/> [?]}</xsl:template>
  <xsl:template match="app//unclear"><xsl:apply-templates/> ut vid.</xsl:template>
  <xsl:template match="q | term">\emph{<xsl:apply-templates/>}</xsl:template> <!-- Does not work in app! -->
  <xsl:template match="pb | cb">
    <xsl:choose>
      <xsl:when test="self::pb">
        <xsl:choose>
          <xsl:when test="parent::p">
            <xsl:text>|\ledsidenote{</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>|\marginpar{</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="translate(./@ed, '#', '')"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="translate(./@n, '-', '')"/>
        <xsl:if test="following-sibling::*[1][self::cb]">
          <xsl:value-of select="following-sibling::cb[1]/@n"/>
        </xsl:if>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="not(preceding-sibling::*[1][self::pb])">
          <xsl:choose>
            <xsl:when test="parent::p">
              <xsl:text>|\ledsidenote{</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>|\marginpar{</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:value-of select="translate(preceding::pb[1]/@ed, '#', '')"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="translate(preceding::pb[1]/@n, '-', '')"/>
          <xsl:value-of select="./@n"/>
          <xsl:text>}</xsl:text>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="lb">
    <xsl:if test="position() &gt; 2">
      <xsl:text>{\\}</xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template match="supplied">\supplied{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="secl">\secluded{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="note">\footnoteA{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="del">\del{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="add">{[}+ <xsl:apply-templates/>, <xsl:value-of select="@place"/>{]}</xsl:template>
  <xsl:template match="seg">
    <xsl:if test="@type='target'">
      <xsl:call-template name="createLabelFromId">
        <xsl:with-param name="labelType">start</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates/>
    <xsl:if test="@type='target'">
      <xsl:call-template name="createLabelFromId">
        <xsl:with-param name="labelType">end</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  <xsl:template match="cit[bibl]">
    <xsl:choose>
      <xsl:when test="./quote">
        <xsl:text>\edtext{\enquote{</xsl:text>
        <xsl:apply-templates select="quote"/>
        <xsl:text>}}{</xsl:text>
        <xsl:if test="count(tokenize(normalize-space(ref), ' ')) &gt; 4">
          <xsl:text>\lemma{</xsl:text>
          <xsl:value-of select="tokenize(normalize-space(ref), ' ')[1]"/>
          <xsl:text> \dots{} </xsl:text>
          <xsl:value-of select="tokenize(normalize-space(ref), ' ')[last()]"/>
          <xsl:text>}</xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:when test="./ref">
        <xsl:text>\edtext{</xsl:text>
        <xsl:apply-templates select="ref"/>
        <xsl:text>}{</xsl:text>
        <xsl:if test="count(tokenize(normalize-space(ref), ' ')) &gt; 4">
          <xsl:text>\lemma{</xsl:text>
          <xsl:value-of select="tokenize(normalize-space(ref), ' ')[1]"/>
          <xsl:text> \dots{} </xsl:text>
          <xsl:value-of select="tokenize(normalize-space(ref), ' ')[last()]"/>
          <xsl:text>}</xsl:text>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
    <xsl:text>\Afootnote{</xsl:text>
    <xsl:apply-templates select="bibl"/>
    <xsl:text>}}</xsl:text>
  </xsl:template>
  <xsl:template match="ref[bibl]">
    <xsl:text>\edtext{</xsl:text>
    <xsl:apply-templates select="seg"/>
    <xsl:text>}{</xsl:text>
    <xsl:if test="count(tokenize(normalize-space(./seg), ' ')) &gt; 10">
      <xsl:text>\lemma{</xsl:text>
      <xsl:value-of select="tokenize(normalize-space(./seg), ' ')[1]"/>
      <xsl:text> \dots\ </xsl:text>
      <xsl:value-of select="tokenize(normalize-space(./seg), ' ')[last()]"/>
      <xsl:text>}</xsl:text>
    </xsl:if>
    <xsl:text>\Afootnote{</xsl:text>
    <xsl:apply-templates select="bibl"/>
    <xsl:text>}}</xsl:text>
  </xsl:template>
  <xsl:template match="ref"><xsl:apply-templates/></xsl:template>

  <xsl:template name="substring-after-last">
    <!-- Based on XSLT Cookbook p. 28-31 -->
    <xsl:param name="input"/>
    <xsl:param name="substr"/>

    <!-- Get string that follows first occurrence -->
    <xsl:variable name="temp" select="substring-after($input, $substr)"/>

    <xsl:choose>
      <!-- If it still contains the search string, continue recursively -->
      <xsl:when test="$substr and contains($temp, $substr)">
        <xsl:call-template name="substring-after-last">
          <xsl:with-param name="input" select="$temp"/>
          <xsl:with-param name="substr" select="$substr"/>
        </xsl:call-template>
      </xsl:when>
      <!-- Else, return the temporary string, as it comes after last instance of
           the string we were looking for -->
      <xsl:otherwise>
        <xsl:value-of select="$temp"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!-- The apparatus template -->
  <xsl:template match="app">
    <xsl:variable name="preceding-tokens" select="tokenize(normalize-space(substring(string-join(preceding::text(), ''), string-length(string-join(preceding::text(), '')) - 100)), ' ')" />
    <xsl:variable name="lemmaContent">
      <xsl:choose>
        <xsl:when test="./lem and not(./lem = '')">1</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:text>\edtext{</xsl:text>
    <xsl:apply-templates select="lem"/>
    <xsl:text>}{</xsl:text>
    <xsl:choose>
      <xsl:when test="count(tokenize(normalize-space(./lem), ' ')) &gt; 10">
        <xsl:text>\lemma{</xsl:text>
        <xsl:value-of select="tokenize(normalize-space(./lem), ' ')[1]"/>
        <xsl:text> \dots\ </xsl:text>
        <xsl:value-of select="tokenize(normalize-space(./lem), ' ')[last()]"/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\lemma{</xsl:text>
        <xsl:apply-templates select="lem"/>
        <xsl:text>}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="$lemmaContent = 1">
        <xsl:text>\Bfootnote{</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\Bfootnote[nosep]{</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:for-each select="./rdg">
      <xsl:call-template name="varianttype">
        <xsl:with-param name="precedingWord" select="$preceding-tokens[last()]" />
      </xsl:call-template>
    </xsl:for-each>
    <xsl:if test="./note">
      <xsl:text> Note: </xsl:text><xsl:value-of select="normalize-space(note)"/>
    </xsl:if>
    <xsl:text>}}</xsl:text>
  </xsl:template>


  <xsl:template match="name">
    <xsl:variable name="nameid" select="substring-after(./@ref, '#')"/>
    <xsl:text> \name{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text><xsl:text>\index[persons]{</xsl:text><xsl:value-of select="document($name-list-file)//tei:person[@xml:id=$nameid]/tei:persName[1]"/><xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="title">
    <xsl:variable name="workid" select="substring-after(./@ref, '#')"/>
    <xsl:text>\worktitle{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text><xsl:text>\index[works]{</xsl:text><xsl:value-of select="document($work-list-file)//tei:bibl[@xml:id=$workid]/tei:title[1]"/><xsl:text>}</xsl:text>
  </xsl:template>
  <xsl:template match="mentioned">
    <xsl:text>\enquote*{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="quote"><xsl:apply-templates/></xsl:template>
  <xsl:template match="rdg"></xsl:template>
  <xsl:template match="app/note"></xsl:template>


  <xsl:template name="varianttype">
    <xsl:param name="precedingWord" />
    <xsl:choose>
      <xsl:when test="./del">
        <xsl:value-of select="./del"/>
        <xsl:text> \emph{post} </xsl:text>
        <xsl:value-of select="$precedingWord"/>
        <xsl:text> \emph{del.} </xsl:text>
        <xsl:call-template name="getWitSiglum"/>
      </xsl:when>
      <xsl:when test="./add">
        <xsl:value-of select="./add"/>
        <xsl:call-template name="getLocation" />
        <xsl:text> \emph{add.} </xsl:text>
        <xsl:call-template name="getWitSiglum"/>
      </xsl:when>
      <xsl:when test="./space">
        <xsl:text>\emph{post} </xsl:text>
        <xsl:value-of select="$precedingWord"/>
        <xsl:text> \emph{vac. </xsl:text>
        <xsl:call-template name="getExtent" />
        <xsl:text>} </xsl:text>
        <xsl:call-template name="getWitSiglum"/>
      </xsl:when>
      <xsl:when test="./subst">
        <xsl:value-of select="./subst/add"/>
        <xsl:text> \emph{corr. ex} </xsl:text>
        <xsl:value-of select="./subst/del"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="getWitSiglum"/>
      </xsl:when>
      <xsl:when test="./unclear/@reason = 'rasura'">
        <xsl:text>\emph{post} </xsl:text>
        <xsl:value-of select="$precedingWord"/>
        <xsl:text> \emph{ras. </xsl:text>
        <xsl:call-template name="getExtent" />
        <xsl:text> litteras} </xsl:text>
        <xsl:call-template name="getWitSiglum"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/><xsl:text> </xsl:text>
        <xsl:call-template name="getWitSiglum"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="./note">
      <xsl:text> (</xsl:text><xsl:value-of select="normalize-space(./note)"/><xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="getExtent">
    <xsl:value-of select=".//@extent" />
    <xsl:choose>
      <xsl:when test=".//@extent &lt; 1">
        <xsl:choose>
          <xsl:when test=".//@unit = 'chars'"> litteram</xsl:when>
          <xsl:when test=".//@unit = 'words'"> verbum</xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test=".//@unit = 'chars'"> litteras</xsl:when>
          <xsl:when test=".//@unit = 'words'"> verba</xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>



  <xsl:template name="getLocation">
    <xsl:choose>
      <xsl:when test="./add/@place='above'">
        <xsl:text> \textit{sup. lin.}</xsl:text>
      </xsl:when>
      <xsl:when test="contains(./add/@place, 'margin')">
        <xsl:text> \textit{in marg.}</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="createLabelFromId">
    <xsl:param name="labelType" />
    <xsl:if test="@xml:id">
      <xsl:choose>
        <xsl:when test="$labelType='start'">
          <xsl:text>\edlabelS{</xsl:text>
          <xsl:value-of select="@xml:id"/>
          <xsl:text>}</xsl:text>
        </xsl:when>
        <xsl:when test="$labelType='end'">
          <xsl:text>\edlabelE{</xsl:text>
          <xsl:value-of select="@xml:id"/>
          <xsl:text>}</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>\edlabel{</xsl:text>
          <xsl:value-of select="@xml:id"/>
          <xsl:text>}</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="getWitSiglum">
    <xsl:variable name="appnumber"><xsl:number level="any" from="tei:text"/></xsl:variable>
    <xsl:if test=".//unclear">
      <xsl:text>\emph{ut vid.} </xsl:text>
    </xsl:if>
    <xsl:value-of select="translate(./@wit, '#', '')"/>
    <xsl:if test=".//@hand">
      <xsl:text>\hand{</xsl:text>
      <xsl:for-each select=".//@hand">
        <xsl:value-of select="translate(., '#', '')"/>
        <xsl:if test="not(position() = last())">, </xsl:if>
      </xsl:for-each>
      <xsl:text>}</xsl:text>
    </xsl:if>

    <xsl:text> n</xsl:text><xsl:value-of select="$appnumber"></xsl:value-of>
  </xsl:template>

</xsl:stylesheet>
