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

    <xsl:template match="seg | anchor | rs">

        <!-- if we're already processing a passage, don't recursively process nested passages (such as an 'rs' inside a 'seg') -->
        <xsl:param name="insidePassage" tunnel="true"/>
        
        <xsl:choose>
            <xsl:when test="$insidePassage">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="processPassage"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>

    <xsl:function name="dpr:entityNoteFromRef">
        <xsl:param name="ref"/>
        <xsl:sequence select="dpr:GetElementById($ref)/descendant-or-self::note"/>
    </xsl:function>

    <xsl:template name="processPassage">
   
        <xsl:param name="insideNote" tunnel="true"/>
        
        <!-- this is the element the note is refering to -->
        <xsl:variable name="passage" select="."/>

        <!-- this is the note content itself -->
        <xsl:variable name="note" as="node()*">
            
            <xsl:choose>
                
                <!-- if we have a seg/anchor, then find a note whose target contains an id that equals the @id on this seg/anchor (i.e., points from note to seg) -->
                <xsl:when test="self::seg or self::anchor">
                    <xsl:sequence select="//(note|metamark)[@target and tokenize(@target,' ')[dpr:GetElementById(., root($passage)) is $passage]]"/>
                </xsl:when>
                
                <!-- if we have an rs, then find the note pointed to by the @ref on the rs (i.e., points from rs to note) --> 
                <xsl:when test="self::rs">

                    <xsl:if test="not(@ref)">
                        <xsl:message terminate="yes">
                            <xsl:text>Element 'rs' must have @ref attribute&#10;</xsl:text>
                            <xsl:value-of select="dpr:XpathOfNode(.)"/>
                        </xsl:message>
                    </xsl:if>
                    
                    <xsl:sequence select="dpr:entityNoteFromRef(@ref)"/>
                    
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:message terminate="yes">
                        <xsl:text>Unexpected element '{local-name(.)}'&#10;</xsl:text>
                        <xsl:value-of select="dpr:XpathOfNode(.)"/>
                    </xsl:message>
                </xsl:otherwise>
                
            </xsl:choose>
                
        </xsl:variable>
        
        <!-- we should have found exactly one note (except in the case of rs, where it's ok if the note is missing) -->
        <xsl:if test="not(count($note) = 1 or (self::rs and count($note)=0))">
            <xsl:message terminate="yes">
                <xsl:text>Found {count($note)} notes pointing to '{local-name(.)}' with id '{@xml:id}'&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode(.)"/>
                <xsl:for-each select="$note">
                    <xsl:text>&#10;</xsl:text><xsl:value-of select="dpr:XpathOfNode(.)"/>
                </xsl:for-each>
            </xsl:message>
        </xsl:if>
        
        <!-- if the passage contains entity references, than the note must refer to those same entities -->
        <xsl:variable name="EntitiesInPassage" as="node()*">
            <xsl:for-each select="$passage//rs/@ref">
                <xsl:sequence select="dpr:GetElementById(.)"></xsl:sequence>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="EntitiesInNote" as="node()*">
            <xsl:for-each select="$note//rs/@ref">
                <xsl:sequence select="dpr:GetElementById(.)"></xsl:sequence>
            </xsl:for-each>
        </xsl:variable>
        <!--<xsl:if test="$EntitiesInPassage except $EntitiesInNote">
            <xsl:message terminate="yes">
                <xsl:text>Found a passage that contains a refence to entity '{($EntitiesInPassage except $EntitiesInNote)[1]/@xml:id}', but that entity is not refenced the 'note' corresponding to that passage&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode($passage)"/>
            </xsl:message>
        </xsl:if>-->

        <xsl:if test="not($passage/self::anchor)">
    
            <!-- what category of note? -->
            <xsl:variable name="noteCategory" select="dpr:getNoteCategory($passage, $note)"/>
            
            <!-- CSS class used to hide/show the bracket based on mode (i.e., process/product/reading -->
            <xsl:variable name="modeClass" as="xs:string?">
                <xsl:choose>
                    <xsl:when test="$noteCategory = 'Metamark'">processModeOn</xsl:when>
                    <xsl:when test="$noteCategory = 'TargetedAuthorial'">readingModeOff</xsl:when>
                </xsl:choose>
            </xsl:variable>
            
            <!-- CSS class used to hide/show the bracket based on sessiom (i.e., slider position) -->
            <xsl:variable name="sessionClass">
                <xsl:text/>
                <!-- TODO: What's this for? -->
            </xsl:variable>
            
            <!-- open bracket -->        
            <xsl:if test="$modeClass">
                <span class="{$modeClass}">
                    <span class="{$sessionClass} passageBracket">
                        <xsl:text expand-text="no">{</xsl:text>
                    </span>                    
                </span>
            </xsl:if>
            
            <!-- passage that the note refers to -->        
            <span>
                
                <xsl:attribute name="class">
                    <xsl:text>passage passageType_{$noteCategory}</xsl:text>
                    <xsl:if test="$noteCategory = 'TargetedAuthorial' or $noteCategory = 'TargetedEditorial' or $noteCategory = 'NamedEntity'">
                        <xsl:text> popupNote</xsl:text>
                    </xsl:if>
                </xsl:attribute>
                
                <xsl:attribute name="data-notecontent">#note_{generate-id($note)}</xsl:attribute>
                
                <xsl:apply-templates>
                    <xsl:with-param name="insidePassage" select="true()" tunnel="yes"/>
                </xsl:apply-templates>                    
                
                <xsl:if test="$noteCategory = 'TargetedAuthorial'">
                    <span style="color:red" class="readingModeOn">
                        <xsl:text>*</xsl:text>
                    </span>
                </xsl:if>
            </span>
            
            <xsl:if test="$insideNote">
                <span style="vertical-align:super; font-size: smaller; line-height: normal">
                    <xsl:value-of select="dpr:indexOfPassageInNote($passage)"/>
                </span>
            </xsl:if>
            
            <!-- close bracket -->        
            <xsl:if test="$modeClass">
                <span class="{$modeClass}">
                    <span class="{$sessionClass} passageBracket">
                        <xsl:text expand-text="no">}</xsl:text>
                    </span>                    
                </span>
            </xsl:if>
            
        </xsl:if>
            
        <!-- the note itself -->
        <xsl:if test="$note and not($insideNote)">
            <xsl:call-template name="processNote">
                <xsl:with-param name="passage" select="$passage"/>
                <xsl:with-param name="note" select="$note"/>
            </xsl:call-template>
        </xsl:if>
        
    </xsl:template>

    <!-- looks at element types and attributes to determine the note category -->
    <xsl:function name="dpr:getNoteCategory" as="xs:string">
        
        <xsl:param name="passage" as="node()?"/>
        <xsl:param name="note" as="node()?"/>

        <xsl:choose>
            <xsl:when test="$passage/self::rs">NamedEntity</xsl:when>
            
            <!-- TODO: Temporarily removed "and $note/@target" below - need to revisit how metamarks without targets work
            <xsl:when test="$note/self::metamark and $note/@target">Metamark</xsl:when>
            -->
            <xsl:when test="$note/self::metamark">Metamark</xsl:when>            
            <xsl:when test="$note/self::note and $note/@type='editorial' and $note/@target">TargetedEditorial</xsl:when>
            <xsl:when test="$note/self::note and $note/@type='authorial' and $note/@target">TargetedAuthorial</xsl:when>
            <xsl:when test="$note/self::note and $note/@type='authorial'">UntargetedAuthorial</xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">
                    <xsl:text>Unexpected note category&#10;</xsl:text>
                    <xsl:value-of select="dpr:XpathOfNode($passage)"/><xsl:text>&#10;</xsl:text>                        
                    <xsl:value-of select="dpr:XpathOfNode($note)"/><xsl:text>&#10;</xsl:text>                        
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="dpr:indexOfPassageInNote">
        <xsl:param name="rs"/>
        <xsl:sequence select="count($rs/ancestor::note//rs intersect $rs/preceding::rs)+1"/>
    </xsl:function>
    
    <!-- output a note or metamark -->
    <xsl:template name="processNote" expand-text="no">
    
        <!--
        Added expand-text="no" above, to work around issue whee an extra space is being emitted before the colon.
        But don't fully undestand the behavior. Posted quesiton to stack overflow: 
        http://stackoverflow.com/questions/35967703/xslt-expand-text-yes-causes-extra-whitespace-in-the-output
        Author of saxon confirmed this is a bug in verison 9.6, fixed in 9.7.
        Remove this hack when we move to 9.7 (don't forget to remove the expand-text="yes" below as well, at the same time).
        And also the other instance of this hack in the "l" template in line.xsl
        -->
    
        <xsl:param name="passage" as="node()?"/>
        <xsl:param name="note" as="node()"/>
        <xsl:param name="insideNote" tunnel="true"/>
        
        <xsl:variable name="noteCategory" select="dpr:getNoteCategory($passage, $note)"/>
        
        <span id="note_{generate-id($note)}">

            <xsl:if test="not($insideNote)">
                <xsl:attribute name="class" expand-text="yes">note noteType_{$noteCategory}</xsl:attribute>
            </xsl:if>

            <xsl:if test="$passage/self::anchor">
                <span style="color:#DD0000; text-transform:uppercase">

                    <xsl:text>{</xsl:text>
                    <xsl:choose>
                        <xsl:when test="ancestor::lg">
                            <xsl:text>line group</xsl:text>
                        </xsl:when>
                        <xsl:when test="ancestor::div[1]/@type">
                            <xsl:value-of select="ancestor::div[1]/@type"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:message terminate="yes">
                                <xsl:text>Found anchor element that has no appropriate lg/div ancestor&#10;</xsl:text>
                                <xsl:value-of select="dpr:XpathOfNode(.)"/>                        
                            </xsl:message>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>}</xsl:text>

                </span>                
            </xsl:if>            
            
            <span>
                
                <xsl:if test="$noteCategory = 'TargetedAuthorial'">
                    <xsl:attribute name="style" select="'color:#DD0000'"/>
                </xsl:if>

                <!-- the note itself -->
                <xsl:apply-templates select="$note/child::node()">
                    <xsl:with-param name="insideNote" select="true()" tunnel="yes"/>
                </xsl:apply-templates>
                
                <!-- spit out the @resp if present -->
                <xsl:if test="$note/@resp">
                    
                    <xsl:if test="$note/@type != 'editorial'">
                        <xsl:message terminate="yes">
                            <xsl:text>@resp is only expected on editorial notes&#10;</xsl:text>
                            <xsl:value-of select="dpr:XpathOfNode($note)"/>
                        </xsl:message>            
                    </xsl:if>
                    
                    <!-- get the target of the @resp -->
                    <xsl:variable name="resp" select="dpr:GetElementById($note/@resp)"/>
                    
                    <!-- make sure the target is of the correct type -->
                    <xsl:if test="not($resp/self::editor or $resp/self::author or $resp/self::respStmt)">
                        <xsl:message terminate="yes">
                            <xsl:text>@resp points to a '{local-name($resp)}' instead of an 'editor', 'author' or 'respStmt'&#10;</xsl:text>
                            <xsl:value-of select="dpr:XpathOfNode(.)"/><xsl:text>&#10;</xsl:text>
                            <xsl:value-of select="dpr:XpathOfNode($note)"/><xsl:text>&#10;</xsl:text>
                            <xsl:value-of select="dpr:XpathOfNode($resp)"/>
                        </xsl:message>            
                    </xsl:if>
                    
                    <!-- output the resp initials in square brackets -->
                    <!-- The expand-text="yes" here is only needed here due to hack mentioned at the top of this function.
                         remove it when that hack goes away. -->
                    <xsl:text expand-text="yes"> [{substring-after($note/@resp, '#')}]</xsl:text>
                                   
                    <!-- show any notes corresponding to entity references inside this note -->
                    <xsl:for-each select="$note//rs" expand-text="yes">
                        
                        
                        <br/>
                        <br/>
                        ({dpr:indexOfPassageInNote(.)}) 
                        <xsl:call-template name="processNote">
                            <xsl:with-param name="passage" select="."/>
                            <xsl:with-param name="note" select="dpr:entityNoteFromRef(@ref)"/>
                            <xsl:with-param name="insideNote" select="true()" tunnel="yes"/>
                        </xsl:call-template>
                        
                    </xsl:for-each>

                                   
                </xsl:if>
                
            </span>
            
        </span>
                
    </xsl:template>
    
    <!-- text in a <desc> should be blue and small caps -->
    <xsl:template match="desc">

        <!-- TODO: I have commented this out sometimes I use <desc> elsewhere. We are going to eventually
        drop <desc> entirely and use <ab> instead - see the priorities document - but until we do I need <desc> 
        in a number of places to make things look right
        
        <xsl:if test="not(ancestor::note or ancestor::metamark)">
            <xsl:message terminate="yes">
                <xsl:text>Unexpected 'desc' element not inside 'note' or 'metamark'&#10;</xsl:text>
                <xsl:value-of select="dpr:XpathOfNode(.)"/>
            </xsl:message>
        </xsl:if>
        -->
        
        <span style="color:#0000FF; font-variant:small-caps">
            <xsl:apply-templates/>
        </span>
    
    </xsl:template>
    
    <!-- note/metamark -->
    <xsl:template match="note|metamark">
        
        <!-- we only need to deal with untargeted notes (targeted ones will be dealt with as part of processing the refering seg/rs) -->
        <xsl:if test="not(@target)">
            <xsl:call-template name="processNote">
                <xsl:with-param name="note" select="."/>
            </xsl:call-template>
        </xsl:if>            
        
    </xsl:template>
    
</xsl:stylesheet>