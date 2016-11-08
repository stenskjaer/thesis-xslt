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
  <xsl:variable name="name-list-file">../../lists/prosopography.xml</xsl:variable>
  <xsl:variable name="work-list-file">../../lists/workscited.xml</xsl:variable>
  <xsl:variable name="app_entry_separator">;</xsl:variable>

  <xsl:output method="text" indent="no"/>
  <xsl:strip-space elements="*"/>
  <!-- <xsl:template match="text()"> -->
  <!--     <xsl:value-of select="normalize-space(.)"/> -->
  <!-- </xsl:template> -->
  <xsl:template match="text()">
      <xsl:value-of select="replace(., '\s+', ' ')"/>
  </xsl:template>

  <xsl:template match="/">
    \section*{<xsl:value-of select="$author"/>: <xsl:value-of select="$title"/>}
    \addcontentsline{toc}{section}{<xsl:value-of select="$author"/>: <xsl:value-of select="$title"/>}
    <xsl:apply-templates select="//body"/>
  </xsl:template>

  <xsl:template match="head">\section*{<xsl:apply-templates/>}</xsl:template>

  <xsl:template match="p">
    <xsl:variable name="pn"><xsl:number level="any" from="tei:text"/></xsl:variable>
    <xsl:text>

    \pstart</xsl:text>
    <xsl:call-template name="createLabelFromId">
      <xsl:with-param name="labelType">start</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="createStructureNumber"/>
    <xsl:apply-templates/>
    <xsl:call-template name="createLabelFromId">
      <xsl:with-param name="labelType">end</xsl:with-param>
    </xsl:call-template>
    <xsl:text>
    \pend</xsl:text>
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

  <xsl:template match="head">
  </xsl:template>

  <xsl:template match="body">
    \begin{latin}
    \beginnumbering
    <xsl:apply-templates/>
    \endnumbering
    \end{latin}
  </xsl:template>

  <xsl:template match="front/div">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name="createStructureNumber">
    <xsl:param name="structure-types">
      <n>rationes-principales</n>
      <n>opposita</n>
      <n>determinatio</n>
      <n>ad-rationes</n>
    </xsl:param>
    <!--
        1. if p.type
        type-name = p@type.value
        1.1 if p.n (= subsection)
        section-number = p@n.value
        2. elif parent::div@type
        type-name = parent::div@type.value
        2.1 if parent::div@n
        section-number = parent::div@n.value
    -->
    <xsl:choose>
      <xsl:when test="@type = $structure-types/*">
        <xsl:choose>
          <xsl:when test="@n">
            <xsl:call-template name="printStructureNumber">
              <xsl:with-param name="type-name" select="@type"/>
              <xsl:with-param name="section-number" select="@n"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="printStructureNumber">
              <xsl:with-param name="type-name" select="@type"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="parent::div[1]/@type = $structure-types/*">
        <xsl:choose>
          <xsl:when test="parent::div[1]/@n">
            <xsl:call-template name="printStructureNumber">
              <xsl:with-param name="type-name" select="parent::div[1]/@type"/>
              <xsl:with-param name="section-number" select="parent::div[1]/@n"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="printStructureNumber">
              <xsl:with-param name="type-name" select="parent::div[1]/@type"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="printStructureNumber">
    <xsl:param name="type-name"/>
    <xsl:param name="section-number"/>
    <xsl:text>
    \no{</xsl:text>
    <xsl:choose>
      <xsl:when test="$type-name = 'rationes-principales'">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:when test="$type-name = 'opposita'">
        <xsl:text>2</xsl:text>
      </xsl:when>
      <xsl:when test="$type-name = 'determinatio'">
        <xsl:text>3</xsl:text>
      </xsl:when>
      <xsl:when test="$type-name = 'ad-rationes'">
        <xsl:text>4</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="$section-number">
      <xsl:text>.</xsl:text>
      <xsl:value-of select="$section-number"/>
    </xsl:if>
    <xsl:text>}
    </xsl:text>
  </xsl:template>

   <!-- Wrap supplied, secluded, notes, and unclear in appropriate tex macros -->
  <xsl:template match="supplied">\supplied{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="surplus">\secluded{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="note">\footnoteA{<xsl:apply-templates/>}</xsl:template>
  <xsl:template match="unclear">\emph{<xsl:apply-templates/> [?]}</xsl:template>

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

  <xsl:template match="cit">
    <xsl:text>\edtext{</xsl:text>
    <xsl:apply-templates select="ref"/>
    <xsl:apply-templates select="quote"/>
    <xsl:text>}</xsl:text>
    <xsl:text>{</xsl:text>
     <xsl:if test="count(tokenize(normalize-space(quote), ' ')) &gt; 4">
      <xsl:text>\lemma{</xsl:text>
      <xsl:value-of select="tokenize(normalize-space(quote), ' ')[1]"/>
      <xsl:text> \dots{} </xsl:text>
      <xsl:value-of select="tokenize(normalize-space(quote), ' ')[last()]"/>
      <xsl:text>}</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="bibl"/>
    <xsl:apply-templates select="note"/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="bibl">
    <xsl:text>\Afootnote{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="ref">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="cit/note">
    <xsl:text>\Afootnote{Note: </xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="quote">
    <xsl:choose>
      <xsl:when test="@type='paraphrase'">
        <xsl:apply-templates />
      </xsl:when>
      <xsl:when test="@type='direct' or not(@type)">
        <xsl:text>\enquote{</xsl:text>
        <xsl:apply-templates />
        <xsl:text>}</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="name">
    <xsl:variable name="nameid" select="substring-after(./@ref, '#')"/>
    <xsl:text> \name{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text><xsl:text>\index[persons]{</xsl:text><xsl:value-of select="document($name-list-file)//tei:person[@xml:id=$nameid]/tei:persName[1]"/><xsl:text>} </xsl:text>
  </xsl:template>

  <xsl:template match="title">
    <xsl:text>\worktitle{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
    <xsl:choose>
      <xsl:when test="./@ref">
        <xsl:variable name="workid" select="substring-after(./@ref, '#')"/>
        <xsl:variable name="canonical-title" select="document($work-list-file)//tei:bibl[@xml:id=$workid]/tei:title[1]"/>
        <xsl:text>\index[works]{</xsl:text>
        <xsl:choose>
          <xsl:when test="$canonical-title">
            <xsl:value-of select="$canonical-title"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>No work with the id <xsl:value-of select="$workid"/> in workslist file (<xsl:value-of select="$work-list-file"/>)</xsl:message>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="no">No reference given for title/<xsl:value-of select="."/>.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- THE APPARATUS HANDLING -->
  <xsl:template match="app">
    <!-- Two initial variables -->
    <!-- Store lemma text if it exists? -->
    <xsl:variable name="lemma_text">
      <xsl:choose>
        <xsl:when test="./lem and not(./lem = '')">
          <xsl:value-of select="lem" />
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Register a possible text anchor (for empty lemmas) -->
    <xsl:variable name="preceding_word" select="lem/@n"/>

    <!-- The entry proper -->
    <!-- The critical text -->
    <xsl:text>\edtext{</xsl:text>
    <xsl:apply-templates select="lem"/>
    <xsl:text>}{</xsl:text>

    <!-- The app lemma. Given in abbreviated or full length. -->
    <xsl:choose>
      <xsl:when test="count(tokenize(normalize-space(./lem), ' ')) &gt; 4">
        <xsl:text>\lemma{</xsl:text>
        <xsl:value-of select="tokenize(normalize-space(./lem), ' ')[1]"/>
        <xsl:text> \dots{} </xsl:text>
        <xsl:value-of select="tokenize(normalize-space(./lem), ' ')[last()]"/>
        <xsl:text>}</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\lemma{</xsl:text>
        <xsl:apply-templates select="lem"/>
        <xsl:text>}</xsl:text>
      </xsl:otherwise>
    </xsl:choose>

    <!-- The critical note itself. If lemma is empty, use the [nosep] option -->
    <xsl:choose>
      <xsl:when test="lemma_text = 0">
        <xsl:text>\Bfootnote[nosep]{</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>\Bfootnote{</xsl:text>
      </xsl:otherwise>
    </xsl:choose>

    <!--
        This is the trick part. If we are actually in a <lem>-element instead of
        a <rdg>-element, it entails some changes in the handling of the
        apparatus note.
        We know that we are in a <lem>-element if it is given a reading type.
        TODO: This should check that it is one of the used reading types.
        TODO: Should all reading types be possible in the lemma? Any? It is
        implied by the possibility of having @wit in lemma.
    -->
    <xsl:if test="lem/@type">
      <!-- This loop is stupid, but I need to have the lem-element as the root
           node when handling the variants. -->
      <xsl:for-each select="./lem">
        <xsl:call-template name="varianttype">
          <xsl:with-param name="lemma_text" select="$lemma_text" />
          <xsl:with-param name="fromLemma">1</xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>
    <xsl:for-each select="./rdg">
      <xsl:call-template name="varianttype">
        <xsl:with-param name="preceding_word" select="$preceding_word"/>
        <xsl:with-param name="lemma_text" select="$lemma_text" />
        <xsl:with-param name="fromLemma">0</xsl:with-param>
      </xsl:call-template>
    </xsl:for-each>

    <!-- The possibility of having a note for the whole app entry. -->
    <xsl:if test="./note">
      <xsl:text> Note: </xsl:text><xsl:value-of select="normalize-space(note)"/>
    </xsl:if>

    <!-- Wrap up -->
    <xsl:text>}}</xsl:text>
  </xsl:template>

  <xsl:template name="varianttype">
    <xsl:param name="lemma_text" />
    <xsl:param name="fromLemma" />
    <xsl:param name="preceding_word" />

    <xsl:choose>

      <!-- VARIATION READINGS -->
      <!-- variation-substance -->
      <xsl:when test="@type = 'variation-substance' or not(@type)">
        <xsl:apply-templates select="."/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- variation-orthography -->
       <xsl:when test="@type = 'variation-orthography'">
        <xsl:apply-templates select="."/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- variation-inversion -->
       <xsl:when test="@type = 'variation-inversion'">
        <xsl:text>\emph{inv.} </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- variation-present -->
      <xsl:when test="@type = 'variation-present'">
        <xsl:call-template name="process_empty_lemma_reading">
          <xsl:with-param name="reading_content" select="."/>
          <xsl:with-param name="preceding_word" select="$preceding_word"/>
        </xsl:call-template>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- variation-absent -->
      <!-- TODO: Expand further in accordance with documentation -->
      <xsl:when test="@type = 'variation-absent'">
        <xsl:choose>
          <xsl:when test="./space">
            <xsl:text>\emph{vac. </xsl:text>
            <xsl:call-template name="getExtent"/>
            <xsl:if test="./space/@reason">
              <xsl:text> (</xsl:text>
              <xsl:value-of select="./space/@cause"/>
              <xsl:text>)</xsl:text>
            </xsl:if>
            <xsl:text>} </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>\emph{om.} </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- variation-choice -->
      <!--
          TODO: This also needs implementation of hands, location and segment
          order. I thinks it better to start with a bare bones implementation
          and go from there
      -->
      <xsl:when test="@type = 'variation-choice'">
        <xsl:variable name="seg_count" select="count(choice/seg)"/>
        <xsl:for-each select="choice/seg">
          <xsl:choose>
            <xsl:when test="position() &lt; $seg_count">
              <xsl:choose>
                <xsl:when test="position() = ($seg_count - 1)">
                  <xsl:apply-templates select="."/>
                  <xsl:text> \emph{et} </xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="."/>
                  <xsl:text>, </xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
        <xsl:text> </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- CORRECTIONS -->
      <!-- correction-addition -->
      <xsl:when test="@type = 'correction-addition'">
        <xsl:choose>
          <!-- addition made in <lem> element -->
          <xsl:when test="$fromLemma = 1">
            <xsl:if test="not($lemma_text = .)">
              <xsl:apply-templates select="."/>
            </xsl:if>
          </xsl:when>
          <!-- addition not in lemma element -->
          <xsl:otherwise>
            <xsl:choose>
              <!-- empty lemma text handling -->
              <xsl:when test="$lemma_text = ''">
                <xsl:call-template name="process_empty_lemma_reading">
                  <xsl:with-param name="reading_content" select="add"/>
                  <xsl:with-param name="preceding_word" select="$preceding_word"/>
                </xsl:call-template>
              </xsl:when>
              <!-- reading ≠ lemma -->
              <xsl:when test="not($lemma_text = add)">
                <xsl:apply-templates select="add"/>
              </xsl:when>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="getLocation" />
        <xsl:text> \emph{add.} </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- correction-deletion -->
      <!-- TODO: Implement handling of del@rend attribute -->
      <xsl:when test="@type = 'correction-deletion'">
        <xsl:call-template name="process_empty_lemma_reading">
          <xsl:with-param name="reading_content" select="del"/>
          <xsl:with-param name="preceding_word" select="$preceding_word"/>
        </xsl:call-template>
        <xsl:text> \emph{del.} </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- correction-substitution -->
      <!-- TODO: Take @rend and @place into considerations -->
      <xsl:when test="@type = 'correction-substitution'">
        <xsl:choose>
          <!-- empty lemma text handling -->
          <xsl:when test="$lemma_text = ''">
            <xsl:call-template name="process_empty_lemma_reading">
              <xsl:with-param name="reading_content" select="subst/add"/>
              <xsl:with-param name="preceding_word" select="$preceding_word"/>
            </xsl:call-template>
          </xsl:when>
          <!-- lemma has content -->
          <xsl:otherwise>
            <xsl:apply-templates select="subst/add"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> \emph{corr. ex} </xsl:text>
        <xsl:apply-templates select="subst/del"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- correction-transposition -->
      <xsl:when test="@type = 'correction-transposition'">
        <xsl:choose>
          <xsl:when test="subst/del/seg[@n]">
            <xsl:apply-templates select="subst/del/seg[@n = 1]"/>
            <xsl:text> \emph{ante} </xsl:text>
            <xsl:apply-templates select="subst/del/seg[@n = 2]"/>
            <xsl:text> \emph{transp.} </xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="tokenize(normalize-space(subst/del), ' ')[1]"/>
            <xsl:text> \emph{ante} </xsl:text>
            <xsl:value-of select="tokenize(normalize-space(subst/del), ' ')[last()]"/>
            <xsl:text> \emph{transp.} </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- correction-cancellation subtypes -->
      <!-- TODO: They need to handle hands too -->

      <!-- deletion-of-addition -->
      <xsl:when test="@type = 'deletion-of-addition'">
        <xsl:call-template name="process_empty_lemma_reading">
          <xsl:with-param name="reading_content" select="del/add"/>
          <xsl:with-param name="preceding_word" select="$preceding_word"/>
        </xsl:call-template>
        <xsl:text> \emph{add. et del.} </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- deleton-of-deletion -->
      <xsl:when test="@type = 'deletion-of-deletion'">
        <xsl:apply-templates select="del/del"/>
        <xsl:text> \emph{del. et scr.} </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- deletion-of-substitution -->
      <xsl:when test="@type = 'deletion-of-substitution'">
        <xsl:apply-templates select="del/subst/add"/>
        <xsl:text> \emph{corr. ex} </xsl:text>
        <xsl:apply-templates select="del/subst/del"/>
        <xsl:text> \emph{et deinde correctionem revertavit} </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- substitution-of-addition -->
      <xsl:when test="@type = 'substitution-of-addition'">
        <xsl:apply-templates select="subst/del/add"/>
        <xsl:text> \emph{add. et del. et deinde} </xsl:text>
        <xsl:apply-templates select="subst/add"/>
        <xsl:text> \emph{scr.} </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:when>

      <!-- CONJECTURES -->
      <!-- conjecture-supplied -->
      <xsl:when test="@type = 'conjecture-supplied'">
        <xsl:choose>
          <!-- If we come from lemma element, don't print the content of it -->
          <xsl:when test="$fromLemma = 1"/>
          <xsl:otherwise>
            <xsl:apply-templates select="supplied"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> \emph{suppl.}</xsl:text>
        <xsl:if test="@source">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@source"/>
        </xsl:if>
        <xsl:if test="following-sibling::*">
          <xsl:value-of select="$app_entry_separator"/>
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:when>

      <!-- conjecture-removed -->
      <xsl:when test="@type = 'conjecture-removed'">
        <xsl:choose>
          <!-- empty lemma text handling -->
          <xsl:when test="$lemma_text = ''">
            <xsl:call-template name="process_empty_lemma_reading">
              <xsl:with-param name="reading_content" select="surplus"/>
              <xsl:with-param name="preceding_word" select="$preceding_word"/>
            </xsl:call-template>
          </xsl:when>
          <!-- If we come from lemma element, don't print the content of it -->
          <xsl:when test="$fromLemma = 1"/>
          <xsl:otherwise>
            <xsl:apply-templates select="supplied"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> \emph{secl.}</xsl:text>
        <xsl:if test="@source">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@source"/>
        </xsl:if>
        <xsl:if test="following-sibling::*">
          <xsl:value-of select="$app_entry_separator"/>
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:when>

      <!-- conjecture-corrected -->
      <xsl:when test="@type = 'conjecture-corrected'">
        <xsl:choose>
          <!-- If we come from lemma element, don't repeat the content -->
          <xsl:when test="$fromLemma = 1"/>
          <xsl:otherwise>
            <xsl:apply-templates select="."/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text> \emph{scr.}</xsl:text>
        <xsl:if test="@source">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@source"/>
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="following-sibling::*">
          <xsl:value-of select="$app_entry_separator"/>
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:when>

      <xsl:otherwise>
        <xsl:apply-templates select="."/><xsl:text> </xsl:text>
        <xsl:call-template name="get_witness_siglum"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="note">
      <xsl:text> (</xsl:text>
      <xsl:apply-templates select="note"/>
      <xsl:text>)</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- READING TEMPLATES -->
  <!-- Erasures in readings -->
  <xsl:template match="rdg/space[@reason = 'erasure']">
    <xsl:text>\emph{ras.</xsl:text>
    <xsl:if test="@extent">
      <xsl:text> </xsl:text>
      <xsl:call-template name="getExtent"/>
    </xsl:if>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <!-- Unclear in readings adds an "ut vid." to the note -->
  <xsl:template match="rdg/unclear"><xsl:apply-templates/> ut vid.</xsl:template>

  <!-- APPARATUS HELPER TEMPLATES -->
  <xsl:template name="process_empty_lemma_reading">
    <xsl:param name="reading_content"/>
    <xsl:param name="preceding_word"/>
    <xsl:value-of select="$reading_content"/>
    <xsl:text> \emph{post} </xsl:text>
    <xsl:value-of select="$preceding_word"/>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template name="get_witness_siglum">
    <xsl:variable name="appnumber"><xsl:number level="any" from="tei:text"/></xsl:variable>
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
    <xsl:if test="following-sibling::*">
      <xsl:value-of select="$app_entry_separator"/>
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="getExtent">
    <xsl:value-of select=".//@extent" />
    <xsl:choose>
      <xsl:when test=".//@extent &lt; 2">
        <xsl:choose>
          <xsl:when test=".//@unit = 'characters'"> litteram</xsl:when>
          <xsl:when test=".//@unit = 'words'"> verbum</xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test=".//@unit = 'characters'"> litteras</xsl:when>
          <xsl:when test=".//@unit = 'words'"> verba</xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="getLocation">
    <xsl:choose>
      <xsl:when test="add/@place='above'">
        <xsl:text> \textit{sup. lin.}</xsl:text>
      </xsl:when>
      <xsl:when test="contains(add/@place, 'margin')">
        <xsl:text> \textit{in marg.}</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
