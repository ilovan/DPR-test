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

    <xsl:template match="choice">
        
        <xsl:variable name="FirstChild" select="*[1]"/>
        <xsl:variable name="SecondChild" select="*[2]"/>
        
        <xsl:if test="not($FirstChild/self::sic or $FirstChild/self::orig or $FirstChild/self::abbr)">
            <xsl:message terminate="yes">
                <xsl:text>First child node of choice must be corr, reg, or expan&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode($FirstChild)"/>
            </xsl:message>
        </xsl:if>
        
        <xsl:if test="$FirstChild/self::sic and not($SecondChild/self::corr)">
            <xsl:message terminate="yes">
                <xsl:text>Sic must be followed by corr&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode($SecondChild)"/>
            </xsl:message>            
        </xsl:if>

        <xsl:if test="$FirstChild/self::orig and not($SecondChild/self::reg)">
            <xsl:message terminate="yes">
                <xsl:text>Orig must be followed by reg&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode($SecondChild)"/>
            </xsl:message>            
        </xsl:if>
        
        <xsl:if test="$FirstChild/self::abbr and not($SecondChild/self::expan)">
            <xsl:message terminate="yes">
                <xsl:text>Abbr must be followed by expand&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode($SecondChild)"/>
            </xsl:message>            
        </xsl:if>
        
        <xsl:apply-templates/>
        
    </xsl:template>
    
    <xsl:template match="corr|reg|expan">
        <span class="readingModeOn">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    
    <xsl:template match="sic|orig|abbr">

        <span class="readingModeOff">

            <xsl:choose>

                <xsl:when test="self::sic">
                    <span class="sicText" title="{normalize-space(following-sibling::corr)}">
                        <span style="color:#DD0000"> <!-- TODO: move to css stylesheet -->
                            <xsl:text>[</xsl:text>
                        </span>
                        <xsl:apply-templates/>        
                        <span style="color:#DD0000">
                            <xsl:text>]</xsl:text>
                            <span style="font-variant:small-caps">
                                <xsl:text>sic</xsl:text>
                            </span>
                        </span>
                    </span>
                </xsl:when>

                <xsl:otherwise>
                    <xsl:apply-templates/>        
                </xsl:otherwise>

            </xsl:choose>

        </span>

    </xsl:template>
    

</xsl:stylesheet>