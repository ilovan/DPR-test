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

    <xsl:template name="ProcessSubst">
        
        <xsl:param name="Layers" tunnel="yes"/>
        <xsl:param name="PrevLayer" tunnel="yes"/>
        <xsl:param name="ThisLayer" tunnel="yes"/>
        <xsl:param name="NextLayer" tunnel="yes"/>
        <xsl:param name="subst"/>
        
        <xsl:variable name="del" select="$subst/del"/>
        <xsl:variable name="add" select="$subst/add"/>
        <xsl:variable name="CurrLayer" select="dpr:GetLayerFromSubst($subst)"/>
     
        <!-- Subst may have two child elements, one del then one add -->
        <xsl:if test="not($del) or not($add) or count($subst/*) != 2">
            <xsl:message terminate="yes">
                <xsl:text>Every subst element must have exactly one del and one add&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode($subst)"/>
            </xsl:message>            
        </xsl:if>
        
        <!-- Subst may not contain text -->
        <xsl:if test="$subst/text()[normalize-space()]">
            <xsl:message terminate="yes">
                <xsl:text>Found subst element containing text&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode($subst/text()[normalize-space()][1])"/>
            </xsl:message>            
        </xsl:if>
        
        <!-- TODO: could check that the del always comes before the add, but the XSLT shouldn't actually care -->

        <xsl:variable name="BracketClass" select="'bracketCorrection'"/>
        
        <xsl:variable name="DelBracketClass" as="xs:string*">
            <xsl:value-of select="$BracketClass"/>
            <xsl:value-of select="'processModeOn'"/>
            <xsl:value-of select="dpr:ClassesFromLayerList(dpr:GenerateLayerList($Layers, $NextLayer))"/>
        </xsl:variable>
        
        <xsl:variable name="AddBracketClass" as="xs:string*">
            <xsl:value-of select="$BracketClass"/>
            <xsl:value-of select="'processModeOn'"/>
            <xsl:value-of select="dpr:ClassesFromLayerList(dpr:GenerateLayerList($Layers, $PrevLayer))"/>
        </xsl:variable>
        
        <span style="cursor:default">
            
            <xsl:if test="$CurrLayer = $NextLayer or $CurrLayer &gt; $ThisLayer">
                <xsl:call-template name="ProcessDelOrAdd">
                    <xsl:with-param name="Node" select="$del"/>
                    <xsl:with-param name="Session" select="dpr:GetSessionFromLayer($CurrLayer)"/>
                    <xsl:with-param name="BracketClass" select="$DelBracketClass"/>
                </xsl:call-template>
            </xsl:if>
            
            <xsl:if test="$CurrLayer = $ThisLayer or not($CurrLayer &gt; $ThisLayer)">
                <xsl:call-template name="ProcessDelOrAdd">
                    <xsl:with-param name="Node" select="$add"/>
                    <xsl:with-param name="Session" select="dpr:GetSessionFromLayer($CurrLayer)"/>
                    <xsl:with-param name="BracketClass" select="$AddBracketClass"/>
                </xsl:call-template>
            </xsl:if>
            
        </span>
        
    </xsl:template>
    
    <!-- nested sub element -->
    <xsl:template match="subst">

        <xsl:call-template name="ProcessSubst">
            <xsl:with-param name="subst" select="."/>
        </xsl:call-template>        
        
    </xsl:template>
    
    <!-- top level subst element -->
    <xsl:template match="subst[not(ancestor::subst)]">

        <xsl:variable name="subst" select="."/>
        
        <!-- all the layers referenced anywhere under this del/add pair -->
        <xsl:variable name="Layers" as="xs:string*" select="dpr:GetLayers($subst)"/> 
        
        <!-- gap between sets of changes -->
        <div class="processModeOn">
            <div style="height:5px">&#160;</div>
        </div>
        
        <!-- loop through the layers -->
        <xsl:for-each select="1 to count($Layers)">
            
            <xsl:variable name="i" select="."/>
            <xsl:variable name="ThisLayer" select="$Layers[$i]"/>
            <xsl:variable name="ThisSession" select="dpr:GetSessionFromLayer($ThisLayer)"/>
            
            <xsl:variable name="First" select="$i = 1"/>
            <xsl:variable name="Last" select="$i = count($Layers)"/>
            
            <!-- the outermost <div> that toggles the visibility of this layer in response to the slider -->
            <div class="{string-join(('showLayer', dpr:ClassesFromLayerList(dpr:GenerateLayerList($Layers, $Layers[$i]))), ' ')}">
                
                <!-- the <span> that contains the complete layer -->
                <span class="layerContainer">
                    
                    <!-- the <span> that contains the layer label (e.g., A1, A2, B1, etc.) -->
                    <span class="session{$ThisSession}Color layerLabel">
                        <xsl:value-of select="$ThisSession"/>
                    </span>
                    
                    <!-- the <span> that inserts a gap between the layer label and the content -->
                    <span class="layerSpacer">&#160;</span>
                    
                    <!-- the <span> that includes the layer content -->
                    <span class="session{$ThisSession}Color layerContents"> 
                        
                        <!-- call into ProcessSubst to actually generate the contents of this layer -->
                        <xsl:call-template name="ProcessSubst">
                            <xsl:with-param name="Layers" select="$Layers" tunnel="yes"/>
                            <xsl:with-param name="PrevLayer" select="$Layers[$i - 1]" tunnel="yes"/>
                            <xsl:with-param name="ThisLayer" select="$Layers[$i]" tunnel="yes"/>
                            <xsl:with-param name="NextLayer" select="$Layers[$i + 1]" tunnel="yes"/>
                            <xsl:with-param name="subst" select="$subst"/>
                        </xsl:call-template>
                        
                    </span> <!-- content -->
                    
                </span> <!-- spacer -->
                
            </div> <!-- layer show/hide -->
            
        </xsl:for-each>
        
        <!-- gap between sets of changes -->
        <div class="processModeOn">
            <div style="height:5px">&#160;</div>
        </div>
        
    </xsl:template>
    

</xsl:stylesheet>