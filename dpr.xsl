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

    <xsl:include href="https://raw.githubusercontent.com/ilovan/DPR-test/master/sessionlayer.xsl"/>
    <xsl:include href="https://raw.githubusercontent.com/ilovan/DPR-test/master/deladd.xsl"/>
    <xsl:include href="https://raw.githubusercontent.com/ilovan/DPR-test/master/util.xsl"/>
    <xsl:include href="https://raw.githubusercontent.com/ilovan/DPR-test/master/substjoin.xsl"/>
    <xsl:include href="https://raw.githubusercontent.com/ilovan/DPR-test/master/choice.xsl"/>
    <xsl:include href="https://raw.githubusercontent.com/ilovan/DPR-test/master/emph.xsl"/>
    <xsl:include href="https://raw.githubusercontent.com/ilovan/DPR-test/master/text.xsl"/>
    <xsl:include href="https://raw.githubusercontent.com/ilovan/DPR-test/master/polygons.xsl"/>
    <xsl:include href="https://raw.githubusercontent.com/ilovan/DPR-test/master/subst.xsl"/>
    <xsl:include href="https://raw.githubusercontent.com/ilovan/DPR-test/master/cb.xsl"/>
    <xsl:include href="https://raw.githubusercontent.com/ilovan/DPR-test/master/list.xsl"/>
    <xsl:include href="https://raw.githubusercontent.com/ilovan/DPR-test/master/line.xsl"/>
    <xsl:include href="https://raw.githubusercontent.com/ilovan/DPR-test/master/para.xsl"/>
    <xsl:include href="https://raw.githubusercontent.com/ilovan/DPR-test/master/pb.xsl"/>
    <xsl:include href="https://raw.githubusercontent.com/ilovan/DPR-test/master/note.xsl"/>
    <xsl:include href="https://raw.githubusercontent.com/ilovan/DPR-test/master/images.xsl"/>
    
    <xsl:output method="xhtml" indent="no" encoding="UTF-8" omit-xml-declaration="yes"/>
    
    <xsl:variable name="GlobalSubstJoins" select="//substJoin"/>
    <xsl:variable name="GlobalJoins" select="//join"/>
    <xsl:variable name="GlobalSessions" select="dpr:GetSessions(/)" as="xs:string*"/>
    <xsl:variable name="GlobalLayers" select="dpr:GetLayers(/)" as="xs:string*"/>

    <xsl:template match="//teiHeader"/>
    
    <xsl:template name="outputStyles" expand-text="no">
        
        <style type="text/css">
            
            html, body { height:100%; width:100%; margin:0; padding:0 }
            
            body                                { font-family:calibri; font-size:1em }
            
            .showLayer                          { display:none }

            .bracketNormal, .bracketCorrection  { display:none; font-weight:bold }
            .bracketNormal                      { color:#DD0000 }
            .bracketCorrection                  { color:#DD0000 } /* TODO: put back to #3333FF if we ever go back to brackets */
            
            input[type=button]                  { border:none }
            
            .sicText                            { cursor:default }
            .recteText                          { color:#DD0000 }
            
            .div                                { margin-top:4ex }
            .lg                                 { margin-top:2ex }
            .para                               { margin-top:2ex }
            .item                               { margin-top:1.5ex; margin-bottom:1.5ex }
            .line                               { }

            .passageBracket                     { color:#DD0000 }
            
        </style>
        
        <style type="text/css" id="ShowLayer">
            <xsl:for-each select="$GlobalLayers">
                .showLayer<xsl:value-of select="."/> { }
            </xsl:for-each>
        </style>
        
        <style type="text/css" id="SessionColor">
            <xsl:for-each select="1 to count($GlobalSessions)">
                <xsl:variable name="i" select="."/>
                .session<xsl:value-of select="$GlobalSessions[$i]"/>Color { background-color:<xsl:value-of select="$SessionColors[$i]"/> }
            </xsl:for-each>
        </style>
        
        <style type="text/css" id="MultiLayer">
            .layerContainer  { display: block; margin-left:25px; spacing:0; text-indent:-25px; padding:0 }
            .layerLabel      { display: inline-block; margin:0px; text-indent:0px; width:21px; text-align:center; color:black }
            .layerSpacer     { display: inline; margin:0px; text-indent:0px; width:5px; text-align:center; background-color:white }
            .layerContents   { display: inline; margin:0px; text-indent:0px }
        </style>
        
        <style type="text/css" id="SingleLayer">
            .layerContainer  { display: inline }
            .layerLabel      { display: none }
            .layerSpacer     { display: none }
            .layerContents   { display: inline }
            #substJoinBar    { display: none }                    
        </style>
        
        <style type="text/css" id="ProcessMode">
            
            
            .rendBold                               { font-weight:bold }
            .rendUnderline                          { text-decoration:underline }
            .rendItal                               { font-style:italic }
            .rendSc                                 { font-variant:small-caps }
            .rendallSc                              { font-variant:all-small-caps }
            .rendCaps                               { text-transform:uppercase }
            .rendDqOpen:before, .rendDqBoth:before  { content:"&#x201C;" }
            .rendDqClose:after, .rendDqBoth:after   { content:"&#x201D;" } 
            .rendSqOpen:before, .rendSqBoth:before  { content:"&#x2018;" }
            .rendSqClose:after, .rendSqBoth:after   { content:"&#x2019;" }
            
            .linePart:before                        { content:"[" attr(data-linepart-label) "]"; font-variant:small-caps; color:blue; }
            
            .columnBreak                            { font-variant:small-caps; color:blue; }
            
            .listItem                               { display:block }
            .listItemLabel                          { display:block }
            .listItemRef                            { display:block }
            
            .lineNum                                { display:none }
            .lineNumCell                            { width:0 }
            
            td.lineBracketCell                      { width: 2px }
            td.lineSpacerCell                       { width: 2px }
            
            table.bracketedLine                     { border-spacing: 0px 3px }
            table.bracketedLine td.lineBracketCell  { border:solid blue 2px; border-right:none; }
            
            table.unbracketedLine                   { }
            table.unbracketedLine td.lineBracketCell { border:solid transparent 2px; border-right:none; }

            .bracketDelInstant                      { color:#DD0000 }

            .noteType_Metamark                      { color:#DD0000 }
            .noteType_UntargetedAuthorial           { color:#DD0000 }
            .noteType_TargetedAuthorial             { color:#DD0000 }
            .noteType_TargetedEditorial             { display:none }
            .noteType_NamedEntity                   { display:none }

            .processModeOn { display:inline }
            .processModeOff { display:none }
            .productModeOn { display:none }sc
            .productModeOff { display:inline }
            .readingModeOn { display:none }
            .readingModeOff { display:inline }
            
        </style>
        
        <style type="text/css" id="ProductMode">
            
            .rendBold                               { font-weight:bold }
            .rendUnderline                          { text-decoration:underline }      
            .rendItal                               { font-style:italic }
            .rendSc                                 { font-variant:small-caps }
            .rendAll                              { font-variant:all-small-caps }
            .rendCaps                               { text-transform:uppercase }
            .rendDqOpen:before, .rendDqBoth:before  { content:"&#x201C;" }
            .rendDqClose:after, .rendDqBoth:after   { content:"&#x201D;" } 
            .rendSqOpen:before, .rendSqBoth:before  { content:"&#x2018;" }
            .rendSqClose:after, .rendSqBoth:after   { content:"&#x2019;" }
            
            .linePart:before                        { content:"[" attr(data-linepart-label) "]"; font-variant:small-caps; color:blue; }
            
            .columnBreak                            { font-variant:small-caps; color:blue; }
            
            .listItem                               { display:block }
            .listItemLabel                          { display:block }
            .listItemRef                            { display:block }
            
            .lineNum                                { display:inline-block }
            .lineNumCell                            { width:4ex }
            
            td.lineBracketCell                      { display: none }
            td.lineSpacerCell                       { display: none }

            .bracketDelInstant                      { display:none }
            
            .noteType_Metamark                      { display:none }
            .noteType_UntargetedAuthorial           { display:none }
            .noteType_TargetedAuthorial             { color:#DD0000 }
            .noteType_TargetedEditorial             { display:none }
            .noteType_NamedEntity                   { display:none }

            .processModeOn { display:none }
            .processModeOff { display:inline }
            .productModeOn { display:inline }
            .productModeOff { display:none }
            .readingModeOn { display:none }
            .readingModeOff { display:inline }
            
        </style>
        
        <style type="text/css" id="ReadingMode">
            
            .readingItal                                    { font-style:italic }
            .readingUnItal                                  { font-style:normal }
            .readingDqOpen:before, .readingDqBoth:before    { content:"&#x201C;" }                   
            .readingDqClose:after, .readingDqBoth:after     { content:"&#x201D;" }                    
            .readingSqOpen:before, .readingSqBoth:before    { content:"&#x2018;" }                   
            .readingSqClose:after, .readingSqBoth:after     { content:"&#x2019;" }                    
            .readingLargeBold                               { font-weight:bold; font-size:150% }
            .readingBold                                    { font-weight:bold }
            .readingUnBold                                  { font-weight:normal }
            .readingBoldColon                               { font-weight:bold }
            .readingBoldColon:after                         { font-weight:bold; content:":" }
            .readingHidden                                  { display:none }
            
            .columnBreak                                    { display:none }
            
            .listItem                                       { display:table-cell; vertical-align:top;  }
            .listItemLabel                                  { display:table-cell; vertical-align:top;  width:25ex }
            .listItemRef                                    { display:table-cell; vertical-align:top;  width:5ex }
            
            .lineNum                                        { display:inline-block }
            .lineNumCell                                    { width:4ex }
            
            td.lineBracketCell                              { display: none }
            td.lineSpacerCell                               { display: none }

            .bracketDelInstant                      { display:none }

            .noteType_Metamark                      { display:none }
            .noteType_UntargetedAuthorial           { display:none }
            .noteType_TargetedAuthorial             { display:none }
            .noteType_TargetedEditorial             { display:none }
            .noteType_NamedEntity                   { display:none }

            .passageType_TargetedAuthorial          { background-color:lightGray }
            .passageType_TargetedEditorial          { background-color:lightGray }
            .passageType_NamedEntity                { background-color:lightGray }

            .processModeOn { display:none }
            .processModeOff { display:inline }
            .productModeOn { display:none }
            .productModeOff { display:inline }
            .readingModeOn { display:inline }
            .readingModeOff { display:none }
            
        </style>
        
        <style type="text/css" id="LineBreak">
            div.lineBreak { display:inline }
        </style>
        
        <style type="text/css" id="Highlights"/>
        
        <style type="text/css" id="JoinHighlightSessions">
            <xsl:for-each select="$GlobalSessions">
                .joinMarkerSession_<xsl:value-of select="."/> { }
            </xsl:for-each>
        </style>
        
        <style type="text/css" id="JoinHighlights">
        </style>
        
        <style type="text/css" id="PolygonHighlights">
            .polygonPage { visibility:hidden }
            
            .polygonPageShow { visibility:visible }
            
            .polygonPath { stroke:none; fill:none }
            
            .polygonPageShowHint .polygonPath { fill:#DD0000; fill-opacity:0.25 }
            
            .polygonInsert { stroke:#DD0000; stroke-width:3; stroke-dasharray:3,3; fill:none } 
            .polygonChange { stroke:#DD0000; stroke-width:3; fill:none } 
            .polygonRemove { stroke:#DD0000; stroke-width:3; fill:none } 
            
        </style>

        <style>
            .ui-widget, .ui-tooltip-content {
            font-family: calibri;
            font-size: 1em;            
            }
            
        </style>
        
    </xsl:template>
    
    <xsl:template name="outputLinks">
        
        <!-- jquery -->
        <script src="https://raw.githubusercontent.com/ilovan/DPR-test/master/jquery/js/jquery-1.9.1.js"/>
        <script src="https://raw.githubusercontent.com/ilovan/DPR-test/master/jquery/js/jquery-ui-1.10.3.custom.js"/>
        <script src="jquery.wrap-svg\jquery.wrap-svg.js"/>
        <script>
            jQuery.noConflict();
        </script>
        <link rel="stylesheet" href="https://raw.githubusercontent.com/ilovan/DPR-test/master/jquery\css\smoothness\jquery-ui-1.10.3.custom.css"/>

        <!-- underscore -->
        <script src="https://raw.githubusercontent.com/ilovan/DPR-test/master/underscore/underscore.js"/>
        
        <!-- main js file -->
        <script type="text/javascript" src="https://raw.githubusercontent.com/ilovan/DPR-test/master/dpr.js"/>
        <script type="text/javascript" src="https://raw.githubusercontent.com/ilovan/DPR-test/master/stylesheet.js"/>
        <script type="text/javascript" src="https://raw.githubusercontent.com/ilovan/DPR-test/master/polygons.js"/>
        
        <!-- image viewer control -->
        <script src="https://raw.githubusercontent.com/ilovan/DPR-test/master/zoom_assets/jquery.smoothZoom.js"/>
        <link rel="stylesheet" href="https://raw.githubusercontent.com/ilovan/DPR-test/master/imagectl.css"/>
        
        <!-- page control -->
        <script src="https://raw.githubusercontent.com/ilovan/DPR-test/master/pagectl.js"/>
        <link rel="stylesheet" href="https://raw.githubusercontent.com/ilovan/DPR-test/master/pagectl.css"/>
        
        <!-- slider control -->
        <script type="text/javascript" src="https://raw.githubusercontent.com/ilovan/DPR-test/master/slider.js"/>
        <link rel="stylesheet" href="https://raw.githubusercontent.com/ilovan/DPR-test/master/slider.css"/>                        
        
        <!-- zoom control -->
        <script type="text/javascript" src="https://raw.githubusercontent.com/ilovan/DPR-test/master/zoomctl.js"/>
        
        <!-- substJoin highlighting -->
        <script src="https://raw.githubusercontent.com/ilovan/DPR-test/master/substjoin.js"/>
        <link rel="stylesheet" href="https://raw.githubusercontent.com/ilovan/DPR-test/master/join.css"/>
        
    </xsl:template>
    
    
    <xsl:template name="outputBody" expand-text="no">

        <xsl:variable name="root" select="."/>
        
        <!-- misc data we need from js -->
        <script>
            <xsl:value-of select="dpr:GenerateJavascriptArray('layers', $GlobalLayers)"/>
            <xsl:value-of select="dpr:GenerateJavascriptArray('sessions', $GlobalSessions)"/>
            <xsl:value-of select="dpr:GenerateJavascriptArray('imageFilenames', $ImageFilenames)"/>
            <xsl:value-of select="dpr:GeneratePolygonPageMap()"/>
        </script>
        
        <script>
            
            jQuery(document).ready(function($) {
            
            <xsl:text>var sliderData = [ </xsl:text> 
            <xsl:for-each select="1 to count($GlobalSessions)">
                <xsl:variable name="i" select="."/>
                <xsl:text>{label:'</xsl:text>
                <xsl:value-of select="$GlobalSessions[$i]"/>
                <xsl:text>', color:'</xsl:text>
                <xsl:value-of select="$SessionColors[$i]"/>
                <xsl:text>', description:'</xsl:text>
                <xsl:value-of select="normalize-space($root//listChange/change[$i])"/>
                <xsl:text>'}</xsl:text>
                <xsl:if test="position()!=last()">,</xsl:if>
            </xsl:for-each>
            <xsl:text>];</xsl:text>
            
            $("#slider").Slider(sliderData);                    
            
            document.pageCtl = $("#MyPageCtl").PageCtl(<xsl:value-of select="count($ImageFilenames)"/>, OnPageChange);                    
            $("#PageCtlAnchor").hide();
            
            document.zoomCtl = $("#ZoomCtl").zoomCtl();
            $("#ZoomCtlAnchor").hide();
            
            changeRenderMode.call(document.getElementById('processMode'));
            
            $(document.body)
                .css("height", "100%")
                .css("width", "100%");
                
            // when the mouse passes over the document in reading view, highlight notes in gray
<!--
                //TODO: Bring this back
                $("#cellContent")
                .hover(
                    function()
                    {
                        $(".passage.noteType_seg, .passage.noteType_anchor").css("background-color", document.renderMode == "readingMode" ? "lightGray" : ""); 
                        $(".passage.noteType_rs").css("background-color", document.renderMode == "readingMode" ? "darkGray" : ""); 
                    },
                    function()
                    {
                        $(".passage").css("background-color", "");
                    }
                );
-->            
            $("[data-joinid]")
                .hover(function(e){ OnMouseHover.call(this, e, true); }, function(e){ OnMouseHover.call(this, e, false); });
            
            // add tooltips for choice/sicc/corr
            $(".sicText")
                .tooltip({
                    track: true,
                    content:
                        function ()
                        {
                            var recte = $(this).attr("title").trim();
                            if (recte == "")
                                return '<span class="recteText">~</span>';
                            else
                                return recte;
                        }
                });
            
            // add tooltips for notes (the 'data-notecontent' points to a span that contains the HTML to be used for the note content) 
            $(".popupNote")
                .tooltip({
                    track: true,
                    items: "[data-notecontent]",
                    content:
                        function ()
                        {
                            if (document.renderMode == "readingMode")
                                return $($(this).attr("data-notecontent")).html();
                            else
                                return false;
                        }
                });
 
            

<!--            
            // TODO: bring this code back and fix it
            // Issue: weird hover callback mismatch leaves casues stale highlighting
            
            $(".note")
                .hover(
                    function(event)
                    {
                        console.debug("[IN " + $(this).attr("id") + "]");
                        $("[data-notecontent=#" + $(this).attr("id") + "]").css("color", "#DD0000");
                    },
                    function(event)
                    {
                        console.debug("[OUT " + $(this).attr("id") + "]");
                        $("[data-notecontent=#" + $(this).attr("id") + "]").css("color", "");
                    }
                );

-->
            $(window).resize(positionSubstJoinHighlightDivs);
            
            $("#processMode, #productMode, #readingMode").click(changeRenderMode); 
            
            function mouseEvent(event) 
            {                            
                $(this).toggle();
                $(document.elementFromPoint(event.pageX, event.pageY)).trigger(event);
                $(this).toggle();
            }
            
            $("#svg_document")
                .css("cursor", "move")
                .click(mouseEvent)
                .dblclick(mouseEvent)
                .mousedown(mouseEvent)
                .mouseup(mouseEvent)
                .mousemove(mouseEvent)
                .hover(function(event) { showAllPolyOnPage(document.pageCtl.GetPage(), true) }, function(event) { showAllPolyOnPage(document.pageCtl.GetPage(), false) });
                
            $(".pb")
                .css("cursor", "pointer")
                .click(function() { document.pageCtl.SetPage(Number($(this).attr("data-targetpage"))); });
                                
            initSubstJoinHighlight();

            });
            
        </script>
        
        <div id="cellSlider" style="width:calc(100% - 2ex); height:13ex; padding:1ex; left:0; top:0; position:absolute">
            
            <br/>
            <div id="slider"/>
            <br/>
            <input type="button" id="processMode" value="Process" style="padding:5px; width:130px"/>
            <input type="button" id="productMode" value="Product" style="padding:5px; width:130px"/>
            <input type="button" id="readingMode" value="Reading Text" style="padding:5px; width:130px"/>
            
            <span id="ZoomCtlAnchor" style="display:inline-block; position:absolute">
                <span style="width:0.5em; display:inline-block"/>
                <div id="ZoomCtl"/>
            </span>
            
        </div>                                
        
        <div id="cellContent" style="width:calc(50% - 2ex); height:calc(100% - 17ex); left:0; top:15ex; position:absolute; overflow:auto; padding:1ex">
            
            <table border="0" cellspacing="0" cellpadding="0">
                <tr>
                    <td style="width:15px" valign="top" id="substJoinBar">
                    </td>
                    <td>
                        <xsl:apply-templates/>
                    </td>
                    <td style="width:7px">
                    </td>
                    <td style="width:10px" valign="top" id="pageNavBar" expand-text="yes">
                        <xsl:for-each-group select="//pb" group-by="@n">
                            <div class="pageNavHighlight page{count(preceding::pb)}" data-page="{count(preceding::pb)}" title="Page {@n}" style="position:absolute; width:10px">
                            </div>
                        </xsl:for-each-group>
                    </td>
                </tr>
            </table>
            
        </div>
        
        <div id="cellImage" style="width:50%; height:calc(100% - 15ex); position:absolute; left:50%; top:15ex">
            <div id="yourImageID" style="width:100%; height:100%"/>
        </div>
        
        <span id="MyPageCtl" style="bottom:10px; left:calc(50% + 15px); position:absolute; z-index:20"/>
        
        <xsl:call-template name="GeneratePolygonSVG">
            <xsl:with-param name="root" select="/"/>
        </xsl:call-template>
                        
    </xsl:template>
    
    
    <xsl:template match="/">

        <xsl:call-template name="CheckSubstJoins"/>
        <xsl:call-template name="CheckJoins"/>
        <xsl:call-template name="CheckLineParts"/>
        <xsl:call-template name="CheckPageBreaks"/>
        
        <!-- output the complete HTML file -->
        <html>
            
            <!-- head element, containing styles adn links -->
            <head>                        
                <xsl:call-template name="outputStyles"/>
                <xsl:call-template name="outputLinks"/>
            </head>
            
            <!-- body element, containing the content -->
            <body>
                <xsl:call-template name="outputBody"/>
            </body>
            
        </html>

        <!-- also put the body into a file called "output_body.html" -->
        <xsl:result-document href="output_body.html" omit-xml-declaration="yes">
            <xsl:call-template name="outputBody"/>
        </xsl:result-document>
        
        <!-- and the the styles into a file called "output_styles.html" -->
        <xsl:result-document href="output_styles.html" omit-xml-declaration="yes">
            <xsl:call-template name="outputStyles"/>
        </xsl:result-document>
        
        <!-- and the links into a file called "output_links.html" -->
        <xsl:result-document href="output_links.html" omit-xml-declaration="yes">
            <xsl:call-template name="outputLinks"/>
        </xsl:result-document>
        
    </xsl:template>
        
    <!-- div -->
    <xsl:template match="div">
        <div class="div hideWhenEmpty">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

</xsl:stylesheet>