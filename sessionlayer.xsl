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
    
    <xsl:param name="checkSeqAttribute"/>

    <xsl:variable name="SessionColors" as="xs:string*">
        
        <xsl:sequence select="'#FFBFBF'"/> <!-- red --> 
        <xsl:sequence select="'#FFBF7F'"/> <!-- orange --> 
        <xsl:sequence select="'#FFFF7F'"/> <!-- yellow -->
        <xsl:sequence select="'#7FFF7F'"/> <!-- green -->
        <xsl:sequence select="'#BFBFFF'"/> <!-- blue -->
        <xsl:sequence select="'#CF8FFF'"/> <!-- purple -->
        <xsl:sequence select="'#CFCFCF'"/> <!-- gray -->
        <xsl:sequence select="'#AFAFAF'"/> <!-- gray -->

        <!-- TODO: [NewControlBar] temporarily repeat the same 8 colors (for a total of 26) -->
        <xsl:sequence select="'#FFBFBF'"/> <!-- red --> 
        <xsl:sequence select="'#FFBF7F'"/> <!-- orange --> 
        <xsl:sequence select="'#FFFF7F'"/> <!-- yellow -->
        <xsl:sequence select="'#7FFF7F'"/> <!-- green -->
        <xsl:sequence select="'#BFBFFF'"/> <!-- blue -->
        <xsl:sequence select="'#CF8FFF'"/> <!-- purple -->
        <xsl:sequence select="'#CFCFCF'"/> <!-- gray -->
        <xsl:sequence select="'#AFAFAF'"/> <!-- gray -->        
        <xsl:sequence select="'#FFBFBF'"/> <!-- red --> 
        <xsl:sequence select="'#FFBF7F'"/> <!-- orange --> 
        <xsl:sequence select="'#FFFF7F'"/> <!-- yellow -->
        <xsl:sequence select="'#7FFF7F'"/> <!-- green -->
        <xsl:sequence select="'#BFBFFF'"/> <!-- blue -->
        <xsl:sequence select="'#CF8FFF'"/> <!-- purple -->
        <xsl:sequence select="'#CFCFCF'"/> <!-- gray -->
        <xsl:sequence select="'#AFAFAF'"/> <!-- gray -->
        <xsl:sequence select="'#FFBFBF'"/> <!-- red --> 
        <xsl:sequence select="'#FFBF7F'"/> <!-- orange --> 
        
    </xsl:variable>    

    <!-- don't output anything for <listChange> -->
    <xsl:template match="listChange"/>
        
    <xsl:variable name="ImplicitFirstLayer" select="'A1'"/>
    <xsl:variable name="ImplicitFirstSession" select="dpr:GetSessionFromLayer($ImplicitFirstLayer)"/>
    
    <xsl:function name="dpr:GetSessionFromLayer" as="xs:string">
        <xsl:param name="Layer"/>
        <xsl:value-of select="substring($Layer, 1, 1)"/>
    </xsl:function>
    
    <xsl:function name="dpr:GetLayers" as="xs:string*">
        
        <xsl:param name="node"/>
        
        <xsl:value-of select="$ImplicitFirstLayer"/>
        <xsl:for-each-group select="$node/descendant-or-self::subst" group-by="dpr:GetLayerFromSubst(.)">
            <xsl:sort select="current-grouping-key()"/>                
            <xsl:value-of select="current-grouping-key()"/>
        </xsl:for-each-group>            
        
    </xsl:function>

    <xsl:function name="dpr:GetSessions" as="xs:string*">
        
        <xsl:param name="node"/>
        
        <xsl:for-each-group select="dpr:GetLayers($node)" group-by="dpr:GetSessionFromLayer(.)">
            <xsl:sort select="current-grouping-key()"/>   
            <xsl:value-of select="current-grouping-key()"/>
        </xsl:for-each-group>            
        
    </xsl:function>
    
    <xsl:function name="dpr:ClassesFromLayerList" as="xs:string*">
        <xsl:param name="Layers"/>
        <xsl:for-each select="$Layers">
            <xsl:sequence select="concat('showLayer', ., if (position()!=last()) then ' ' else '')"/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="dpr:GenerateLayerList" as="xs:string*">
        <xsl:param name="Layers"/>
        <xsl:param name="ThisLayer"/>
        <xsl:variable name="NextLayer" select="$Layers[. &gt; $ThisLayer][1]"/>
        <xsl:sequence select="$GlobalLayers[. &gt;= $ThisLayer and not(. &gt;= $NextLayer)]"/>
    </xsl:function>
    
    <xsl:function name="dpr:GetSessionFromSubst" as="xs:string">
        
        <xsl:param name="subst"/>
        
        <!-- must have a @change attribute -->
        <xsl:if test="not($subst/@change)">
            <xsl:message terminate="yes">
                <xsl:text>Subst element must have @change attribute&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode($subst)"/>
            </xsl:message>
        </xsl:if>
        
        <!-- @change must start with # -->
        <xsl:if test="not(starts-with($subst/@change, '#'))">
            <xsl:message terminate="yes">
                <xsl:text>Session ID references must begin with #&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode($subst/@change)"/>
            </xsl:message>
        </xsl:if>
        
        <!-- extrace the stirng after the # -->
        <xsl:variable name="session" select="substring-after($subst/@change, '#')"/>

        <!-- must be a single uppercase letter in the correct range -->
        <xsl:if test="not(matches($session, '^[A-Z]$'))"> <!-- TODO: [NewControlBar] Changed from A-H to A-Z -->
            <xsl:message terminate="yes">
                <xsl:text>Session '</xsl:text><xsl:value-of select="$session"/><xsl:text>' not valid. Must be a single uppercase letter between A and H.&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode($subst/@change)"/>
            </xsl:message>
        </xsl:if>
        
        <!-- the regexp above assumes a max of 8 sessions; fix the regexp if you add to $SessionColors --> 
        <xsl:if test="count($SessionColors) != 26"> <!-- TODO: [NewControlBar] Changed from 8 to 26 -->
            <xsl:message terminate="yes">Internal XSLT error</xsl:message>
        </xsl:if>
        
        <!-- all sessions refrenced in the XML must be defined in <listChange> -->
        <xsl:if test="not(root($subst)//listChange/change[@xml:id=$session])">
            <xsl:message terminate="yes">
                <xsl:text>Session '</xsl:text><xsl:value-of select="$session"/><xsl:text>' not found&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode($subst/@change)"/>
            </xsl:message>
        </xsl:if>
        
        <!-- TODO: It's a bit odd that we're using the xml:id as the user visible session label. Could use the @n attribute on the <change> or something. -->
        
        <xsl:value-of select="$session"/>
        
    </xsl:function>
    
    <xsl:function name="dpr:GetLayerFromSubst" as="xs:string">
        
        <xsl:param name="subst"/>
        
        <xsl:variable name="session" select="dpr:GetSessionFromSubst($subst)"/>
        
        <xsl:variable name="seq" select="count($subst/descendant-or-self::subst[dpr:GetSessionFromSubst(.) = $session]) + (if ($session = $ImplicitFirstSession) then 1 else 0)"/>

        <xsl:variable name="specifiedSeq" select="$subst/@seq"/>

        <xsl:if test="$checkSeqAttribute and $specifiedSeq">
    
            <!-- make sure @seq is an integer that's 1 or greater -->
            <xsl:if test="not($specifiedSeq castable as xs:integer) or $specifiedSeq &lt; 1">
                <xsl:message terminate="yes">
                    <xsl:text>@seq must be a positive integer&#10;</xsl:text>
                    <xsl:value-of select="dpr:XpathOfNode($specifiedSeq)"/>
                </xsl:message>            
            </xsl:if>                
            
            <!-- make sure the @seq for session A is 2 or greater -->
            <xsl:if test="dpr:GetSessionFromSubst($subst)=$ImplicitFirstSession and $specifiedSeq &lt; 2">
                <xsl:message terminate="yes">
                    <xsl:text>Minimum allowable @seq for session A is 2&#10;</xsl:text>
                    <xsl:value-of select="dpr:XpathOfNode($specifiedSeq)"/>
                </xsl:message>            
            </xsl:if>                
        
            <xsl:if test="$specifiedSeq != $seq">
                <xsl:message terminate="{dpr:terminateMessage($checkSeqAttribute)}">
                    <xsl:text>Specified @seq (</xsl:text><xsl:value-of select="$specifiedSeq"/><xsl:text>) </xsl:text>
                    <xsl:text>does not match calculated value (</xsl:text><xsl:value-of select="$seq"/><xsl:text>)&#10;</xsl:text>
                    <xsl:value-of select="dpr:XpathOfNode($specifiedSeq)"></xsl:value-of>
                </xsl:message>
            </xsl:if>
            
        </xsl:if>
                
        <xsl:value-of select="concat(dpr:GetSessionFromSubst($subst), $seq)"/>
        
    </xsl:function>
    
</xsl:stylesheet>