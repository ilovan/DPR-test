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

    <xsl:template match="cb">
        <xsl:call-template name="LineContainer">
            <xsl:with-param name="contents">
                <div class="columnBreak">
                    <xsl:text>[column break]</xsl:text>
                </div>                 
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>