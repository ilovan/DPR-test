<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dpr="http://namespaces.digitalpagereader.org/functions"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs dpr"
    expand-text="yes"
    version="3.0">

    <xsl:template name="CheckLineParts">

        <!-- loop over all lines -->
        <xsl:iterate select="//l">
            
            <!-- this parameter tracks whether we are inside or outside of an initial/final part -->
            <xsl:param name="state" select="'out'"/>
            
            <!-- when we're done, make sure we're not missing a final @part="F" -->
            <xsl:on-completion>
                <xsl:if test="$state='in'">
                    <xsl:message terminate="yes">
                        <xsl:text>Missing final line with @part='F'</xsl:text>
                    </xsl:message>                                        
                </xsl:if>                
            </xsl:on-completion>
            
            <!-- if we're outside and I/F pair, then the only acceptable @part is 'I' or missing -->
            <xsl:if test="$state='out' and not(@part='I' or not(@part))">
                <xsl:message terminate="yes">
                    <xsl:text>Found a line with @part='</xsl:text>
                    <xsl:value-of select="@part"/>
                    <xsl:text>' outside a multi-part line, but the only allowed value is 'I' or missing&#10;</xsl:text>
                    <xsl:value-of select="dpr:XpathOfNode(.)"/>
                </xsl:message>                                        
            </xsl:if>
            
            <!-- if we're inside and I/F pair, then the only acceptable @part is 'M' or 'F' -->
            <xsl:if test="$state='in' and not(@part='M' or @part='F')">
                <xsl:message terminate="yes">
                    <xsl:text>Found a line with @part='</xsl:text>
                    <xsl:value-of select="@part"/>
                    <xsl:text>' inside a multi-part line, but the only allowed value is 'M' or 'F'&#10;</xsl:text>
                    <xsl:value-of select="dpr:XpathOfNode(.)"/>
                </xsl:message>                                                        
            </xsl:if>
            
            <!-- if we see @part='I' transition to 'in', if we see @part='F' transition to 'out', otherwise stay in the same state -->
            <xsl:next-iteration>
                <xsl:with-param name="state">
                    <xsl:choose>
                        <xsl:when test="@part='I'">in</xsl:when>
                        <xsl:when test="@part='F'">out</xsl:when>
                        <xsl:otherwise><xsl:value-of select="$state"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:next-iteration>
            
        </xsl:iterate>
        
    </xsl:template>

    <!-- l -->
    <xsl:template match="l" expand-text="no">
        
        <!-- the expand-text="no" above is a workaround for the same saxon bug mentioned in the 'processNote' template (see note.xsl) -->
        
        <xsl:call-template name="LineContainer">
            
            <xsl:with-param name="showLineNumber" select="not(@part!='I')"/>
            <xsl:with-param name="resetLineNumber" select="ancestor::div[1]/descendant::l[1] intersect ."/>
            <xsl:with-param name="showBracket" select=".//subst"/>
            <xsl:with-param name="contents">

                <!-- do the indentation -->
                <xsl:if test="@rend='indent' or @rend='indent2' or @rend='indent3' or @rend='indent4'">
                    
                    <!-- in proccess/product view show [indent] notation -->
                    <span class="readingModeOff" style="font-variant:small-caps; color:blue">
                        <xsl:text>[</xsl:text>
                        <xsl:choose>
                            <xsl:when test="@rend='indent'">indent</xsl:when>
                            <xsl:when test="@rend='indent2'">double indent</xsl:when>
                            <xsl:when test="@rend='indent3'">triple indent</xsl:when>
                            <xsl:when test="@rend='indent4'">quadruple indent</xsl:when>
                        </xsl:choose>
                        <xsl:text>]</xsl:text>
                    </span>
                    
                    <!-- in reading view show actual indentation -->
                    <span class="readingModeOn">
                        <xsl:attribute name="style">
                            <xsl:text>margin-left:</xsl:text>
                            <xsl:choose>
                                <xsl:when test="@rend='indent'">5</xsl:when>
                                <xsl:when test="@rend='indent2'">10</xsl:when>
                                <xsl:when test="@rend='indent3'">15</xsl:when>
                                <xsl:when test="@rend='indent4'">20</xsl:when>
                            </xsl:choose>
                            <xsl:text>ex</xsl:text>
                        </xsl:attribute>
                        <xsl:text>&#160;</xsl:text>
                    </span>
                    
                </xsl:if>
                
                <!-- show the text -->
                <span>
                    
                    <!-- for lines that are split, show [initial], [medial] or [final] -->
                    <xsl:if test="@part">
                        
                        <xsl:attribute name="class" select="'linePart'"/>
                        <xsl:attribute name="data-linepart-label">
                            <xsl:choose>
                                <xsl:when test="@part='I'">initial</xsl:when>
                                <xsl:when test="@part='M'">medial</xsl:when>
                                <xsl:when test="@part='F'">final</xsl:when>
                                <xsl:otherwise>
                                    <xsl:message terminate="yes">
                                        <xsl:text>Found an 'l' element with @part with invalid value (equal to '</xsl:text><xsl:value-of select="@part"/><xsl:text>')&#10;</xsl:text>
                                        <xsl:value-of select="dpr:XpathOfNode(.)"/>
                                    </xsl:message>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        
                        <!-- indent this line part (show the contents of all previous parts of this line, but with opacity 0%) -->
                        <xsl:variable name="initialLinePart" select="if (@part='I') then . else preceding-sibling::l[@part='I'][1]"/>
                        <xsl:variable name="previousLineParts" select="($initialLinePart union $initialLinePart/following-sibling::l) intersect preceding-sibling::l"/>
                        <xsl:for-each select="$previousLineParts">
                            <span style="opacity:0" class="readingModeOn">
                                <xsl:apply-templates/>
                            </span>
                        </xsl:for-each>
                        
                    </xsl:if>
                                        
                    <!-- actual line contents -->
                    <xsl:apply-templates/>
                    
                    
                </span>
                
            </xsl:with-param>
        </xsl:call-template>
           
    </xsl:template>
    
    <xsl:template name="LineContainer">

        <xsl:param name="showLineNumber" select="false()"/>
        <xsl:param name="resetLineNumber" select="false()"/>
        <xsl:param name="showBracket" select="false()"/>
        <xsl:param name="contents"/>
        
        <!-- LineContainer is meant to be used for block-level elements - it adds the required indentation, line numbering, etc. -->
        <xsl:if test="not(dpr:IsBlockElement(.))">
            <xsl:message terminate="yes">
                <xsl:text>LineContainer called for '{local-name()}', which is not listed in dpr:IsBlockElement&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode(.)"/>
            </xsl:message>
        </xsl:if>

        <xsl:choose>

            <!-- if we're already inside a block-level element, then do nothing special, just output the content -->
            <xsl:when test="ancestor::*[dpr:IsBlockElement(.)]">
                <xsl:copy-of select="$contents"/>
            </xsl:when>

            <!-- if we are the top-most block-level element, then do the magic for line numbering, etc. -->
            <xsl:otherwise>
                
                <table border="0" cellpadding="0" cellspacing="0">
                    
                    <xsl:attribute name="class">
                        <xsl:text>hideWhenEmpty </xsl:text>
                        <xsl:choose>
                            <xsl:when test="$showBracket">
                                <xsl:text>bracketedLine</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>unbracketedLine</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    
                    <tr>
                        <td valign="top" class="lineNumCell">
                                                
                            <xsl:if test="(//div[@type='poem'] or //l) and $showLineNumber">
                                
                                <!-- TODO: remove references to the omit thing from the .js files, etc. -->
                                <span class="lineNum">
                                    
                                    <xsl:if test="$resetLineNumber">
                                        <xsl:attribute name="data-firstline" select="'true'"/> 
                                    </xsl:if>
                                                                
                                </span>
                                
                            </xsl:if>
                            
                        </td>
                        
                        <td class="lineBracketCell"> 
                        </td>
                        
                        <td class="lineSpacerCell"> 
                        </td>
                        
                        <td class="lineContentsCell">
        
                            <xsl:copy-of select="$contents"/>
                            
                        </td>
                    </tr>
                </table>
                    
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
    
    <!-- lg -->
    <xsl:template match="lg">
        <div class="lg hideWhenEmpty">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <!-- lb -->
    <xsl:template match="//lb" name="lineBreak">
        <span class="readingModeOff">
            <span style="color:blue">/</span>
            <br/>
        </span>
    </xsl:template>
    
</xsl:stylesheet>