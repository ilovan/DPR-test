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

    <xsl:template match="list">
        <div style="display:table">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="item">
        
        <xsl:call-template name="LineContainer">
            
            <xsl:with-param name="contents">
                
                <div class="item">

                    <!-- if *any* of the items in this list have a label, then output the label column -->
                    <xsl:if test="ancestor::list/descendant::label">
                        <span class="listItemLabel">
                            <xsl:apply-templates select="label"/>
                        </span>
                    </xsl:if>
                    
                    <!-- output the contents of the item -->
                    <span class="listItem">
                        <xsl:apply-templates select="node() except (ref | label)"/>
                    </span>
                    
                    <!-- output the ref -->
                    <xsl:if test="ref">
                        <span class="listItemRef">
                            <xsl:apply-templates select="ref"/>
                        </span>
                    </xsl:if>
                    
                </div>
                
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
    <!-- make sure all refs and labels are inside an item -->
    <xsl:template match="ref[not(parent::item)] | label[not(parent::item)]">
        <xsl:message terminate="yes">3
            <xsl:text>Parent of '{local-name()}' must be 'item'&#10;</xsl:text>
            <xsl:value-of select="dpr:XpathOfNode(.)"/>
        </xsl:message>        
    </xsl:template>

    <!-- make sure all items are inside a list -->
    <xsl:template match="item[not(parent::list)]">
        <xsl:message terminate="yes">
            <xsl:text>Parent of 'item' must be 'list'&#10;</xsl:text>
            <xsl:value-of select="dpr:XpathOfNode(.)"/>
        </xsl:message>        
    </xsl:template>
    
</xsl:stylesheet>