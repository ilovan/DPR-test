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

    <xsl:template name="CheckJoins">

        <!-- loop over all the <join> elements -->
        <xsl:for-each select="$GlobalJoins">
            
            <xsl:variable name="root" select="/"/>
            
            <!-- for each <join> loop over the IDs in its @target -->
            <xsl:variable name="targets" select="tokenize(normalize-space(@target), ' ')" as="xs:string*"/>
            
            <!-- make sure the first and last targets have the same @rend -->
            <xsl:variable name="firstTargetElem" select="$root//*[@xml:id=substring-after($targets[1], '#')]"/>
            <xsl:variable name="lastTargetElem" select="$root//*[@xml:id=substring-after($targets[last()], '#')]"/>
            <xsl:if test="$firstTargetElem/@rend != $lastTargetElem/@rend">
                <xsl:message terminate="yes">
                    <xsl:text>Found 'join' where first and last targets have mismatched @rend attributes&#10;</xsl:text>
                    <xsl:value-of select="dpr:XpathOfNode($firstTargetElem)"/><xsl:text>&#10;</xsl:text>
                    <xsl:value-of select="dpr:XpathOfNode($lastTargetElem)"/>
                </xsl:message>                
            </xsl:if>            

            <!-- compare consecutive pairs of targets, checking for mismatches -->
            <xsl:for-each select="2 to count($targets)">
                <xsl:variable name="i" select="."/>
                <xsl:variable name="thisTargetElem" select="$root//*[@xml:id=substring-after($targets[$i], '#')]"/>
                <xsl:variable name="previousTargetElem" select="$root//*[@xml:id=substring-after($targets[$i - 1], '#')]"/>
                
                <!-- make sure all 'middle' tagets have no @rend specified -->
                <xsl:if test="$i != 1 and $i != count($targets) and $thisTargetElem/@rend">
                    <xsl:message terminate="yes">
                        <xsl:text>Only the first and last targets of a 'join' may have a @rend specified&#10;</xsl:text>
                        <xsl:value-of select="dpr:XpathOfNode($thisTargetElem)"/>
                    </xsl:message>                    
                </xsl:if>
                
                <!-- make sure the referenced elements are all of the same type -->
                <xsl:if test="local-name($previousTargetElem) != local-name($thisTargetElem)">                        
                    <xsl:message terminate="yes">
                        <xsl:text>Targets of a 'join' must be the same element type&#10;</xsl:text>
                        <xsl:value-of select="dpr:XpathOfNode($previousTargetElem)"/><xsl:text>&#10;</xsl:text>
                        <xsl:value-of select="dpr:XpathOfNode($thisTargetElem)"/>
                    </xsl:message>
                </xsl:if>
                
                <!-- if the referenced elements are <title>s, make sure thye have the same @level value -->
                <xsl:if test="$previousTargetElem/self::title and ($previousTargetElem/@level != $thisTargetElem/@level)">
                    <xsl:message terminate="yes">
                        <xsl:text>Targets of a 'join' that are of type 'title' must have the same @level&#10;</xsl:text>
                        <xsl:value-of select="dpr:XpathOfNode($previousTargetElem/@level)"/><xsl:text>&#10;</xsl:text>
                        <xsl:value-of select="dpr:XpathOfNode($thisTargetElem/@level)"/>
                    </xsl:message>
                </xsl:if>

                <!-- make sure the elements are referenced in the correct order -->
                <xsl:if test="$thisTargetElem/following::* intersect $previousTargetElem">
                    <xsl:message terminate="yes">
                        <xsl:text>Targets of a 'join' must be listed in order&#10;</xsl:text>
                        <xsl:value-of select="dpr:XpathOfNode($previousTargetElem)"/><xsl:text>&#10;</xsl:text>
                        <xsl:value-of select="dpr:XpathOfNode($thisTargetElem)"/>
                    </xsl:message>
                </xsl:if>
                    
                <!-- TODO: make sure the same element isn't referenced from multiple <join> elements -->
                <!-- TODO: make sure there is no unquoted text between the first and last target of a <join> -->

            </xsl:for-each>

        </xsl:for-each>
        
    </xsl:template>

    <!-- there are a number of elements whos rendering in process and product view is controlled by the @rend attribute -->
    <!-- this function calculates the correst CSS class to use, to cause the element to be rendered correctly -->
    <xsl:template name="GenerateClassFromRendAttribute">

        <xsl:variable name="joinPosition" as="xs:string*" select="dpr:JoinPosition(.)"/>
        
        <xsl:choose>
            
            <xsl:when test="@rend='bold'">
                rendBold
            </xsl:when>
            
            <xsl:when test="@rend='italic'">
                rendItal
            </xsl:when>
            
            <xsl:when test="@rend='underline'">
                rendUnderline
            </xsl:when>
            
            <xsl:when test="@rend='sc'">
                rendSc
            </xsl:when>
          
          <xsl:when test="@rend='allSc'">
            rendAllSc
          </xsl:when>
            
            <xsl:when test="@rend='caps'">
                rendCaps
            </xsl:when>
            
            <xsl:when test="@rend='sq'">
                <xsl:choose>
                    <xsl:when test="$joinPosition='first'">rendSqOpen</xsl:when>
                    <xsl:when test="$joinPosition='middle'">rendSqNone</xsl:when>
                    <xsl:when test="$joinPosition='last'">rendSqClose</xsl:when>
                    <xsl:otherwise>rendSqBoth</xsl:otherwise>
                </xsl:choose>               
            </xsl:when>
            
            <xsl:when test="@rend='dq'">
                <xsl:choose>
                    <xsl:when test="$joinPosition='first'">rendDqOpen</xsl:when>
                    <xsl:when test="$joinPosition='middle'">rendDqNone</xsl:when>
                    <xsl:when test="$joinPosition='last'">rendDqClose</xsl:when>
                    <xsl:otherwise>rendDqBoth</xsl:otherwise>
                </xsl:choose>               
            </xsl:when>
            
            <!-- ok to be missing @rend -->
            <xsl:when test="not(@rend)"/>
            
            <xsl:otherwise>
                <xsl:message terminate="yes">
                    <xsl:text>Invalid @rend value '</xsl:text><xsl:value-of select="@rend"/><xsl:text>' on </xsl:text><xsl:value-of select="local-name()"/><xsl:text> element&#10;</xsl:text>
                    <xsl:value-of select="dpr:XpathOfNode(@rend)"/>
                </xsl:message>
            </xsl:otherwise>
            
        </xsl:choose>
        
        <xsl:text> </xsl:text>
            
    </xsl:template>
    
    <!-- this function looks to see if the given element is referenced in a <join> and, if so, where in <join>'s @target
         does this element appear (at the start, middle or end of the list) -->
    <xsl:function name="dpr:JoinPosition">
        
        <xsl:param name="elem"/>

        <!-- loop over all the <join> elements -->
        <xsl:for-each select="$GlobalJoins">
            
            <!-- loop over the IDs listed in the <join>'s @target -->
            <xsl:for-each select="tokenize(normalize-space(@target), ' ')">
                
                <!-- does this this target ID correspond to the current element? -->
                <xsl:if test="concat('#', $elem/@xml:id) = .">
                    <xsl:choose>
                        
                        <!-- if it's the FIRST element in the join, return "first" --> 
                        <xsl:when test="position()=1">first</xsl:when>
                        
                        <!-- if it's the LAST element in the join, return "last" --> 
                        <xsl:when test="position()=last()">last</xsl:when>
                        
                        <!-- if it's any other element in the join, return "middle" --> 
                        <xsl:otherwise>middle</xsl:otherwise>
                        
                    </xsl:choose>
                </xsl:if>
                
            </xsl:for-each>
        
        </xsl:for-each>
    
    </xsl:function>
    
    <!-- a whole slew of elements behavior similarly, so are handled together by this function
         in product and process views, the rendering is conrolled by @rend (logic lives in GenerateClassFromRendAttribute)
         in reading view, the rendering is controlled by the element type (logic lives directly in this template) -->
    <xsl:template match="emph|foreign|mentioned|name|q|quote|soCalled|term|title|hi|label|ref">

        <xsl:if test="self::foreign and not(@xml:lang)">
            <xsl:message terminate="yes">
                <xsl:text>@xml:lang is required on 'foreign' element&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode(.)"/>
            </xsl:message>
        </xsl:if>
        
        <xsl:if test="not(ancestor::*[dpr:IsTextContainingElement(.)])">
            <xsl:message terminate="yes">
                <xsl:text>'</xsl:text><xsl:value-of select='local-name()'/><xsl:text>' must be contained within an element listed in dpr:IsTextContainingElement&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode(.)"/>
            </xsl:message>
        </xsl:if>
                
        <span>
            
            <xsl:attribute name="class">
                    
                <!-- spit out class used by product and process views (controlled by @rend attribute) -->
                <xsl:call-template name="GenerateClassFromRendAttribute"/>                    
                
                <!-- spit out class used by reading view (controled by element type) -->
                <xsl:choose>
                    
                    <!-- emph, foreign, title[@level='m'] and title[@level='j'] are rendered in italic -->
                    <xsl:when test="self::emph or self::foreign or (self::title[@level='m']) or (self::title[@level='j'])">
                        <xsl:choose>
                            <xsl:when test="count(ancestor::emph | ancestor::foreign | ancestor::title[@level='m'] | (self::title[@level='j'])) mod 2 = 0">
                                <xsl:text>readingItal</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>readingUnItal</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    
                    <!-- name, term, hi and label are rendered as normal text -->
                    <xsl:when test="self::name or self::term or self::hi or self::ref">
                        readingNormal
                    </xsl:when>
                    
                    <xsl:when test="self::label">
                        readingBold
                    </xsl:when>
                    
                    <!-- q, quote, soCalled, and title[@level='a'] are rendered in double quotes -->
                    <xsl:when test="self::mentioned or self::q or self::quote or self::soCalled or self::title[@level='a']">
                        
                        <xsl:variable name="quoteType">
                            <xsl:choose>
                                <xsl:when test="count(ancestor::mentioned | ancestor::q | ancestor::quote | ancestor::soCalled | ancestor::title[@level='a']) mod 2 = 0">
                                    <xsl:text>Dq</xsl:text>                                        
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>Sq</xsl:text>                                        
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        
                        <xsl:variable name="joinPosition" as="xs:string*" select="dpr:JoinPosition(.)"/>
                        <xsl:choose>
                            <xsl:when test="$joinPosition='first'">reading<xsl:value-of select="$quoteType"/>Open</xsl:when>
                            <xsl:when test="$joinPosition='middle'">reading<xsl:value-of select="$quoteType"/>None</xsl:when>
                            <xsl:when test="$joinPosition='last'">reading<xsl:value-of select="$quoteType"/>Close</xsl:when>
                            <xsl:otherwise>reading<xsl:value-of select="$quoteType"/>Both</xsl:otherwise>
                        </xsl:choose>
                            
                    </xsl:when>
                        
                    <!-- don't know how to handle <title> with any @level attribute not handled above -->
                    <xsl:when test="self::title">
                        <xsl:message terminate="yes">
                            <xsl:text>Unexpected @level attribute '</xsl:text><xsl:value-of select="@level"/> on title element<xsl:text>'&#10;</xsl:text>
                            <xsl:value-of select="dpr:XpathOfNode(.)"/>
                        </xsl:message>
                    </xsl:when>
                    
                    <!-- don't know how to handle any other elements -->
                    <xsl:otherwise>
                        <xsl:message terminate="yes">
                            <xsl:text>Unexpected element type '</xsl:text><xsl:value-of select="local-name()"/><xsl:text>'&#10;</xsl:text>
                            <xsl:value-of select="dpr:XpathOfNode(.)"/>
                        </xsl:message>
                    </xsl:otherwise>
                    
                </xsl:choose>
                
            </xsl:attribute>

            <xsl:apply-templates/>
            
        </span>
        
    </xsl:template>
    
    
</xsl:stylesheet>