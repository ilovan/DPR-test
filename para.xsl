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
        
    <xsl:function name="dpr:IsParaLikeElement" as="xs:boolean">
        <xsl:param name="node"/>
        <xsl:value-of select="
            $node/self::ab or 
            $node/self::epigraph or 
            $node/self::p or 
            $node/self::head or
            $node/self::dateline or 
            $node/self::byline or 
            $node/self::trailer or 
            $node/self::speaker or
            $node/self::stage"/> 
    </xsl:function>
    
    <xsl:function name="dpr:IsBlockElement" as="xs:boolean">
        <xsl:param name="node"/>
        <xsl:value-of select="
          dpr:IsParaLikeElement($node) or 
            $node/self::cit or 
            $node/self::l or 
            $node/self::item or
            $node/self::fw or
            $node/self::pb or
            $node/self::cb or
            $node/self::docTitle or
            $node/self::docAuthor"/>
    </xsl:function>

    <xsl:function name="dpr:IsTextContainingElement" as="xs:boolean">
        <xsl:param name="node"/>
        <xsl:value-of select="
            dpr:IsBlockElement($node) or 
            $node/self::note or
            $node/self::metamark"/>
    </xsl:function>

    <!-- p, head, etc. -->
    <xsl:template match="*[dpr:IsParaLikeElement(.)]">
        
        <xsl:call-template name="LineContainer">
            <xsl:with-param name="contents">
                
                <!-- div should get class="para" for all block-level elements except <head> since head shouldn't be preceeded by a vertical space, the way other block level elements are -->
                <div class="{if (not(self::head)) then 'para' else ''} hideWhenEmpty">
        
                    <!-- TODO: Can we eliminate this nested span and put the classes directly on the parent div? -->
                    <span>
                        
                        <xsl:attribute name="class">    
                            
                            <!-- spit out class used by product and process views (controlled by @rend attribute) -->
                            <xsl:call-template name="GenerateClassFromRendAttribute"/>
                            
                            <!-- spit out class used by reading view -->
                            <xsl:choose>
                                
                              <xsl:when test="self::ab or self::epigraph or self::p or self::label or self::trailer or self::stage"> <!-- TODO: stage probably needs some special treatment -->
                                    <!-- no special treatment needed -->
                                </xsl:when>
        
                                <xsl:when test="self::head">
                                    
                                    <xsl:choose>
                                        
                                        <!-- head inside div[@type='section'] is rendered in large and bold font -->
                                        <xsl:when test="parent::div[@type='section']">
                                            <xsl:text>readingLargeBold</xsl:text>
                                        </xsl:when>
                                        
                                        <!-- head inside div[@type='poem'] or div[@type='section'] is rendered in bold -->
                                        <xsl:when test="parent::div[@type='poem' or @type='sequence']">
                                            <xsl:text>readingBold</xsl:text>
                                        </xsl:when>
                                        
                                        <!-- head inside div[@type='list'] is rendered as normal text -->
                                        <xsl:when test="parent::div[@type='list']">
                                            <xsl:text>readingNormal</xsl:text>
                                        </xsl:when>
                                        
                                    </xsl:choose>
                                    
                                </xsl:when>
                                
                                <xsl:when test="self::dateline or self::byline">
                                    <xsl:text>readingHidden</xsl:text>
                                </xsl:when>
                                
                                <!-- speaker is rendered bold with a colon -->
                                <xsl:when test="self::speaker">
                                    <xsl:text>readingBoldColon</xsl:text>
                                </xsl:when>

                                <xsl:otherwise>
                                    <xsl:message terminate="yes">
                                        <xsl:text>Unexpected element type '{local-name()}'&#10;</xsl:text>
                                        <xsl:value-of select="dpr:XpathOfNode(.)"/>
                                    </xsl:message>
                                </xsl:otherwise>
                                
                            </xsl:choose>
                            
                        </xsl:attribute>
                        
                        <xsl:apply-templates/>
                        
                    </span>
                    
                </div>
                
            </xsl:with-param>
        </xsl:call-template>
                
    </xsl:template>
    
    <!-- TODO: docTitle/docAuthor implementation not finalized; use at your own risk -->
    <xsl:template match="docTitle|docAuthor">
        
        <xsl:if test="not(ancestor::titlePage)">
            <xsl:message terminate="yes">
                <xsl:text>Element '</xsl:text><xsl:value-of select="local-name()"/><xsl:text>' must be descendant of 'titlePage'&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode(.)"/>
            </xsl:message>
        </xsl:if>
        
        <xsl:call-template name="LineContainer">
            <xsl:with-param name="contents">
                <span>
                    
                    <xsl:attribute name="class">
                        <xsl:choose>
                            <xsl:when test="self::docTitle">readingLargeBold</xsl:when>
                            <xsl:when test="self::docAuthor">readingBold</xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    
                    <xsl:apply-templates/>
                    
                </span>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>