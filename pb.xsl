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

    <xsl:template name="CheckPageBreaks">

        <xsl:if test="//subst//pb">
            <xsl:message terminate="yes">
                <xsl:text>Found pb element inside a subst&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode((//subst//pb)[1])"/><xsl:text>&#10;</xsl:text>
            </xsl:message>            
        </xsl:if>
        
        <xsl:for-each-group select="//pb" group-by="@n">
            <xsl:if test="count(current-group()) != 1">
                <xsl:message terminate="yes">
                    <xsl:text>Found more than one pb with the same @n value&#10;</xsl:text>
                    <xsl:value-of select="dpr:XpathOfNode(current-group()[1]/@n)"/><xsl:text>&#10;</xsl:text>
                    <xsl:value-of select="dpr:XpathOfNode(current-group()[2]/@n)"/><xsl:text>&#10;</xsl:text>
                </xsl:message>                            
            </xsl:if>
        </xsl:for-each-group>
        
    </xsl:template>    

    <!-- pb -->
    <xsl:template match="//pb">

        <!-- TODO: seems like pb can appear inside a block element (e.g., p) or outside, which messes up indentation -->
                
        <xsl:call-template name="LineContainer">
            <xsl:with-param name="contents">        

                <span class="readingModeOff pb page{count(preceding::pb)}" style="color:blue" data-targetpage="{count(preceding::pb)}">
                    ____________________________
                    <br/>
                    [<xsl:value-of select='@n'/>]
                    <br/>
                    
                    <!-- TODO: uncomment this, and don't forget to adjust the selector for textElems in substJoin.js -->
                    <!--
                    <xsl:variable name="n" select="@n"/>
                    <xsl:variable name="thisPb" select="."/>
                    <xsl:variable name="nextPb" select="(following::pb)[1]"/>
                    <xsl:variable name="elemsOnPage" select="$thisPb/following::* intersect (if ($nextPb) then $nextPb/preceding::* else //*)"/>
                    <xsl:if test="not($elemsOnPage[dpr:IsTextContainingElement(.)])">
                        <span style="font-variant: small-caps">
                            <xsl:choose>
                                <xsl:when test="$Polygons[@pageName=$n]">[revisions]</xsl:when>
                                <xsl:otherwise>[blank]</xsl:otherwise>
                            </xsl:choose>
                        </span>
                        <br/>
                        <br/>
                    </xsl:if>
                    -->
                    
                </span>                
                
            </xsl:with-param>
        </xsl:call-template>


    </xsl:template>
        
    <!-- fw -->
    <xsl:template match="fw">

        <xsl:if test="not(@type='header' or @type='footer')">
            <xsl:message terminate="yes">
                <xsl:text>Unrecognized type attribute on 'fw'&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode(.)"/>
            </xsl:message>
        </xsl:if>

        <span class="readingModeOff" style="color:gray">
            <xsl:call-template name="LineContainer">
                <xsl:with-param name="contents">
                    <xsl:apply-templates/>
                    <br/>
                </xsl:with-param>
            </xsl:call-template>
        </span>
        
    </xsl:template>
    
</xsl:stylesheet>