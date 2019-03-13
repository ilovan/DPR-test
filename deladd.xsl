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
    
    <!-- disallow del and add elements outside a subst -->
    <xsl:template match="del|add">
        <xsl:message terminate="yes">
            <xsl:text>Found </xsl:text><xsl:value-of select="local-name()"/><xsl:text> element outside of a subst&#10;</xsl:text>
            <xsl:value-of select="dpr:XpathOfNode(.)"/>
        </xsl:message>
    </xsl:template>    

    <!-- Processes the contents of a del or add element. Handles tilde and paragraph mark. -->
    <xsl:template name="ProcessDelOrAddConents">
        
        <xsl:param name="node"/>
        <xsl:param name="TildeClass"/>
        
        <xsl:choose>
            <xsl:when test="normalize-space($node)='' and not($node/*)">
                <span class="{$TildeClass}">~</span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$node/node()"/>
            </xsl:otherwise>
        </xsl:choose>
                
    </xsl:template>
    
    <xsl:template name="ProcessDelOrAdd">
    
        <xsl:param name="Node"/>
        <xsl:param name="PrevLayer" tunnel="yes"/>
        <xsl:param name="ThisLayer" tunnel="yes"/>
        <xsl:param name="NextLayer" tunnel="yes"/>
        <xsl:param name="Session"/>
        <xsl:param name="BracketClass"/>
        
        <xsl:param name="subst" select="$Node/.."/>
        <xsl:param name="substID" select="$subst/@xml:id"/>

        <xsl:variable name="isDeletion" select="$Node/self::del and $NextLayer = dpr:GetLayerFromSubst($subst)"/>
        <xsl:variable name="isAddition" select="$Node/self::add and $ThisLayer = dpr:GetLayerFromSubst($subst)"/> 
                
        <span>
             
            <xsl:if test="$Node/@facs and $subst/@facs">
                <xsl:message terminate="yes">
                    <xsl:text>Found '{local-name($Node)}' and parent 'subst' that both have @facs specified&#10;</xsl:text>
                    <xsl:value-of select="dpr:XpathOfNode($Node)"/><xsl:text>&#10;</xsl:text>
                    <xsl:value-of select="dpr:XpathOfNode($subst)"/>
                </xsl:message>
            </xsl:if>
            
            <xsl:variable name="facs" select="if ($Node/@facs) then $Node/@facs else $subst/@facs"/>
            <xsl:if test="$facs">
                <xsl:attribute name="data-polygons" select="$facs"/>
            </xsl:if>
            
            <xsl:variable name="joinID">
                <xsl:choose>
                    <xsl:when test="$substID">
                        <xsl:variable name="substID" select="concat('#', $substID)"/>
                        <xsl:value-of select="generate-id($GlobalSubstJoins[tokenize(@target, ' ')[. = $substID]])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="generate-id($subst)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:attribute name="id" select="generate-id($subst)"/>
            
            <xsl:attribute name="data-joinid">
                <xsl:value-of select="$joinID"/>
            </xsl:attribute> 
            
            <xsl:if test="$isDeletion or $isAddition"> 
                <xsl:attribute name="class">
                    <xsl:if test="$Node/self::add and $substID">
                        <xsl:text>join </xsl:text>
                    </xsl:if>
                    <xsl:text>join_</xsl:text><xsl:value-of select="$joinID"/><xsl:text> </xsl:text>
                    <xsl:text>mode_</xsl:text><xsl:value-of select="local-name($Node)"/>
                </xsl:attribute>
            </xsl:if>
            
            <!-- TODO: attach event via jquery in dpr.xsl -->
            <xsl:attribute name="onclick">
                <xsl:text>OnClick(event)</xsl:text>
            </xsl:attribute>
            
            <xsl:attribute name="data-state" select="local-name($Node)"/>
            <xsl:attribute name="data-session" select="$Session"/>
            
            <xsl:if test="$Node/@instant='true' and $isDeletion">
                <span class="bracketDelInstant">&lt;</span>
            </xsl:if>
        
            <span class="processModeOn">&#x200b;</span> <!-- zero-width space; workaround for IE bug 486496 -->

            <xsl:call-template name="ProcessDelOrAddConents">
                <xsl:with-param name="node" select="$Node"/>
                <xsl:with-param name="TildeClass" select="$BracketClass"/>
            </xsl:call-template>

            <xsl:if test="$Node/@instant='true' and $isDeletion">
                <span class="bracketDelInstant">&gt;</span>
            </xsl:if>
            
        </span>
            
    </xsl:template>
    
</xsl:stylesheet>