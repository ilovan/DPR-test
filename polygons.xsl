<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:poly="http://namespaces.digitalpagereader.org/polygon"
    xmlns:dpr="http://namespaces.digitalpagereader.org/functions"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs poly dpr"
    expand-text="yes"
    version="3.0">

    <xsl:param name="checkUnreferencedPolygonID"/>
    
    <xsl:variable name="Polygons" select="document('polygons.xml')//poly:polygon"/>
    <!-- TODO: make sure max($Polygons/@page) is consistent with count($ImageFilenames) -->
    
    <xsl:function name="dpr:GetPolygon">
        <xsl:param name="id"/>
        <xsl:sequence select="$Polygons[@id = $id]"/>
    </xsl:function>
    
    <xsl:template name="CheckPolygons">
  
        <xsl:param name="root"/>
        
        <!-- make sure all the IDs are unique -->
        <xsl:for-each-group select="$Polygons/@id" group-by=".">
            <xsl:if test="count(current-group()) &gt; 1">
                <xsl:message terminate="yes">
                    <xsl:text>Polygon id '</xsl:text><xsl:value-of select="current-grouping-key()"/><xsl:text>' used more than once&#10;</xsl:text>
                    <xsl:for-each select="current-group()">
                        <xsl:value-of select="dpr:XpathOfNode(.)"/>
                        <xsl:text>&#10;</xsl:text>
                    </xsl:for-each>
                </xsl:message>
            </xsl:if>
        </xsl:for-each-group>        

        <!-- make sure every ID mentioned in each @facs attribute actually exists in polygons.xml -->
        <xsl:for-each select="$root//@facs">
            <xsl:variable name="facs" select="."/>
            <xsl:for-each select="tokenize(normalize-space(.), ' ')">
                <xsl:variable name="id" select='.'/>
                <xsl:if test="not(dpr:GetPolygon($id))">
                    <xsl:message terminate="yes">
                        <xsl:text>Polygon id '</xsl:text><xsl:value-of select="."/><xsl:text>' referenced, but never defined&#10;</xsl:text>
                        <xsl:value-of select="dpr:XpathOfNode($facs)"/>
                    </xsl:message>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>

        <!-- make sure every ID in polygons.xml is mentioned in a @facs attribute -->
        <xsl:if test="$checkUnreferencedPolygonID">
            <xsl:for-each select="$Polygons/@id">
                <xsl:variable name="id" select="."/>
                <xsl:if test="not($root//*[tokenize(@facs, ' ')[. = $id]])">
                    <xsl:message terminate="{dpr:terminateMessage($checkUnreferencedPolygonID)}">
                        <xsl:text>Polygon id '</xsl:text><xsl:value-of select="$id"/><xsl:text>' defined, but never referenced&#10;</xsl:text>
                    </xsl:message>                
                </xsl:if>
            </xsl:for-each>
        </xsl:if>
        
        <!-- @facs only allowed on <del>, <add>, <subst> -->
        <xsl:for-each select="$root//*[@facs and not(self::del | self::add | self::subst)]">
            <xsl:message terminate="yes">
                <xsl:text>Found @facs on a '{local-name(.)}' element; only allowed on del, add or subst&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode(.)"/>
            </xsl:message>
        </xsl:for-each>
                
    </xsl:template>
    
    <xsl:template name="GeneratePolygonSVG">
        
        <xsl:param name="root"/>

        <xsl:call-template name="CheckPolygons">
            <xsl:with-param name="root" select="$root"/>
        </xsl:call-template>
        
        <svg id="svg_document" style="width:50%; height:calc(100% - 15ex); position:absolute; left:50%; top:15ex; z-index:10; overflow:hidden"> <!-- pointer-events:none; -->
            
            <g id="svg_pages">
                <xsl:for-each-group select="$Polygons" group-by="@page">
                    
                    <g id="svg_page_{current-grouping-key()}" class="polygonPage">
                        
                        <xsl:for-each select="current-group()">
                            
                            <g id="{@id}" class="polygonGroup">
                                
                                <!-- temporarily remove text -->
                                <xsl:comment>
                                    <xsl:if test="normalize-space(@text) != ''">
                                        <text style="font-family:calibri; font-weight:bold; font-size:1em; fill:#DD0000" text-anchor="middle" alignment-baseline="middle" x="{(@left+@right) div 2}px" y="{(@top+@bottom) div 2}px" dy="0.5ex" class="polygonText polygonContent">
                                            <!-- removed stroke="white" stroke-width="0.1ex" -->                                        
                                            <xsl:value-of select="@text"/>
                                        </text>
                                    </xsl:if>
                                </xsl:comment>

                                <path d="{@path}" style="" class="polygonPath polygonContent"/>
                                
                            </g>

                        </xsl:for-each>
                    </g>
                </xsl:for-each-group>
            </g>
        </svg>
        
    </xsl:template>

    <xsl:function name="dpr:GeneratePolygonPageMap" expand-text="no">
        var polygonPages = {
        <xsl:for-each select="$Polygons">
            '<xsl:value-of select="@id"/>' : 
            {
                page: <xsl:value-of select="@page"/>,
                left: <xsl:value-of select="@left"/>,
                top: <xsl:value-of select="@top"/>,
                right: <xsl:value-of select="@right"/>,
                bottom: <xsl:value-of select="@bottom"/>
            }
            <xsl:if test="position()!=last()">
            ,
            </xsl:if>
        </xsl:for-each>
        };
    </xsl:function>
        
</xsl:stylesheet>