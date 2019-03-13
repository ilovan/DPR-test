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

    <xsl:function name="dpr:NameOfNode" as="xs:string">
        <xsl:param name="Node"/>
        <xsl:variable name="Name">
            <xsl:choose>
                <xsl:when test="$Node instance of attribute()">
                    <xsl:value-of select="concat('@', name($Node))"/>
                </xsl:when>
                <xsl:when test="$Node instance of text()">
                    <xsl:value-of select="'text()'"/>                
                </xsl:when>
                <xsl:when test="$Node instance of comment()">
                    <xsl:value-of select="'comment()'"/>                
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="name($Node)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="Position">
            <xsl:choose>
                <xsl:when test="$Node instance of attribute()"/>
                <xsl:when test="$Node instance of text()">
                    <xsl:value-of select="count($Node/preceding-sibling::text())+1"/>
                </xsl:when>
                <xsl:when test="$Node instance of comment()">
                    <xsl:value-of select="count($Node/preceding-sibling::comment())+1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="count($Node/preceding-sibling::*[name()=name($Node)])+1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($Name, if ($Position != '') then concat('[', $Position, ']') else '')"/>
    </xsl:function>
    
    <xsl:function name="dpr:XpathOfNode">
        <xsl:param name="Node"/>
        <xsl:if test="$Node and $Node/..">
            <xsl:value-of select="concat(dpr:XpathOfNode($Node/..), '/', dpr:NameOfNode($Node))"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="dpr:GenerateJavascriptArray" expand-text="no">
        <xsl:param name="Name"/>
        <xsl:param name="List"/>
        
        var <xsl:value-of select="$Name"/> = [
        <xsl:for-each select="$List">
            "<xsl:value-of select="."/>"
            <xsl:if test="position()!=last()">,</xsl:if>
        </xsl:for-each>
        ];
                
    </xsl:function>
    
    <xsl:function name="dpr:terminateMessage">
        <xsl:param name="mode"/>
        <xsl:variable name="modeNorm" select="normalize-space($mode)"/>
        <xsl:choose>
            <xsl:when test="$modeNorm = 'error'">yes</xsl:when>
            <xsl:when test="$modeNorm = 'warning'">no</xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">
                    <xsl:text>Invalid value '</xsl:text><xsl:value-of select="$modeNorm"/><xsl:text>' passed in for stylesheet parameter</xsl:text>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="dpr:GetElementById">
        <xsl:param name="ref"/>
        <xsl:sequence select="dpr:GetElementById($ref, root($ref))"/>
    </xsl:function>
    
    <!-- TODO: this function may be usable elsewhere (look for places where we parse '#' out of URL) -->
    <xsl:function name="dpr:GetElementById">
        <xsl:param name="ref"/>
        <xsl:param name="doc"/>
        
        <!-- get the target URL (may be blank, indicating "current doc") -->
        <xsl:variable name="refUrl" select="substring-before($ref, '#')"/>
        
        <!-- get the ID of the target (must not be blank) -->
        <xsl:variable name="refFragment" select="substring-after($ref, '#')"/>
        <xsl:if test="not($refFragment)">
            <xsl:message terminate="yes">
                <xsl:text>ref argument to GetElementById ({$ref}) must include ID&#10;</xsl:text>
            </xsl:message>
        </xsl:if>
    
        <!-- get the doc that contains the target attribute -->
        <xsl:variable name="doc" as="node()">
            <xsl:choose>
                <xsl:when test="$refUrl">
                    <xsl:sequence select="document($refUrl)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$doc"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- make sure the doc exists -->
        <xsl:if test="not($doc)">
            <xsl:message terminate="yes">
                <xsl:text>Cannot find referenced document {$refUrl}&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode($ref)"/>
            </xsl:message>            
        </xsl:if>

        <!-- get the specified node from the doc -->
        <xsl:variable name="node" select="$doc//*[@xml:id = $refFragment]"/>

        <!-- make sure the node exists -->
        <xsl:if test="not($node)">
            <xsl:message terminate="yes">
                <xsl:text>Cannot find referenced node {$ref}&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode($ref)"/>
            </xsl:message>            
        </xsl:if>
        
        <!-- return the node -->
        <xsl:sequence select="$node"/>

    </xsl:function>
    
</xsl:stylesheet>