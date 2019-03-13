
function sessionFromLayer(layer)
{
    if (layer == undefined)
        return undefined;
    else
        return layer.substring(0,1);
}

function applySessionFilter(startSessionIndex, endSessionIndex)
{

    var $ = jQuery;
    
    var rules = getStyleSheet("ShowLayer").cssRules;
    var startSession = sessions[startSessionIndex];
    var endSession = sessions[endSessionIndex];
    
    var fProcessMode = (document.renderMode == "processMode"); 
    var fProductMode = (document.renderMode == "productMode");
    var fReadingMode = (document.renderMode == "readingMode");
    var fSingleLayer = (fProductMode || fReadingMode);
    
    for (layerIndex=0; layerIndex<layers.length; layerIndex++)
    {
        var rule = rules[layerIndex];
        var layer = layers[layerIndex];
        var session = sessionFromLayer(layer);
        
        var showThisLayer = (session >= startSession && session <= endSession);
        if (fSingleLayer && sessionFromLayer(layers[layerIndex+1]) == session)
            showThisLayer = false;
        
        rule.style.display = showThisLayer ? "inline" : "";
    }

    //TODO: clean this up (inefficient getStyleSheet within loop, etc.) maybe move to join.js
    for (sessionIndex=0; sessionIndex<sessions.length; sessionIndex++)
    {
        var rules = getStyleSheet("JoinHighlightSessions").cssRules;
        var rule = rules[sessionIndex];
        var showThisSession = (sessionIndex >= startSessionIndex && sessionIndex <= endSessionIndex);
        rule.style.display = (showThisSession ? "" : "none");
    }

    getStyleSheet("MultiLayer").disabled = fSingleLayer;
    getStyleSheet("SingleLayer").disabled = !fSingleLayer;
    
    getStyleSheet("SessionColor").disabled = fSingleLayer; 
    getStyleSheet("LineBreak").disabled = !fSingleLayer;

    getStyleSheet("ProcessMode").disabled = !fProcessMode;
    getStyleSheet("ProductMode").disabled = !fProductMode;
    getStyleSheet("ReadingMode").disabled = !fReadingMode;

    if (fProductMode || fReadingMode)
    {
        var styleSheet = getStyleSheet("Highlights");
        var rules = styleSheet.cssRules;
        for (i=0; i<rules.length; i++)
        {
            var rule = rules[i];
            if (styleSheet.removeRule) styleSheet.removeRule(i);
            else if (styleSheet.deleteRule) styleSheet.deleteRule(i);
        }
    }

    $(".lineNum").each(function(){
        $(this).html("").hide();
    });

    setNewLineVisibility();

    if (!fProcessMode)
    {
        var lineNum = 0;
        $(".lineNum").each(function(){
         
            // if this line has the "data-firstline" attribute, reset the line numbering
            if ($(this).attr("data-firstline") == "true")
                lineNum = 0;
    
            // if the contents of the line is empty, don't show a line number
            if ($(this).closest(".hideWhenEmpty").length > 0 && ($(this).closest(".hideWhenEmpty").width() <= 0 || $(this).closest(".hideWhenEmpty").height() <= 0))
                return;
            
            $(this).css("display", "inline-block");
            
            // if this line has the "data-omitline" attribute, skip over it
            if ($(this).attr("data-omitline"))
                return;
    
            // increment the line number
            lineNum++;
    
            // in reading mode, skip all but every 5th line
            if (document.renderMode == "readingMode" && (lineNum % 5) != 0)
                return;
                
            // insert the line number into the span
            $(this).html(lineNum);
       
        });
    }
    
    positionSubstJoinHighlightDivs();

    // TODO: Maybe a method on ZoomCtl?
    $("#ZoomCtlAnchor")
        .appendTo(document.body)
        .hide();


}

function setNewLineVisibility()
{
    $ = jQuery;
    $(".hideWhenEmpty").each(function(){
        $(this).toggle($(this).width() > 0 && $(this).height() > 0);       
    });
}

function changeRenderMode()
{

    var buttonClicked = this;
    var slider = document.getElementById("slider").slider;
    var knob = slider.knob;

    var buttons = 
        [ 
            document.getElementById("processMode"),
            document.getElementById("productMode"),
            document.getElementById("readingMode")
        ];

    for (i=0; i<buttons.length; i++)
    {
        var button = buttons[i];
        button.style.backgroundColor = (button == buttonClicked) ? "#BFBFBF" : "#DFDFDF"; 
    }
    
    document.renderMode = buttonClicked.id;

    var showOneLayer = (document.renderMode != "processMode");
    knob.SetSingleSelectMode(showOneLayer);

    positionSubstJoinHighlightDivs();

}

function OnMouseHover(e, on)
{

    e.stopPropagation();
    
    var elem = $(this).closest("[data-polygons]");
    var polygons = elem.attr("data-polygons");
    var empty = (elem.children().eq(1).text() == "~");
    
    var action;
    if (empty)
        action = (elem.attr("data-state") == "add") ? "polygonRemove" : "polygonInsert";
    else
        action = "polygonChange";

    if (polygons)
        highlightPolygon(on, this, polygons, action);
        
    hoverHighlight(on, this);

}


function OnClick(e)
{

    var event = e ? e : window.event;
    var elem = event.target ? event.target : event.srcElement;
    event.stopPropagation();

    hoverHighlight(true, elem);

}

function manageHighlightStyles(on, elem)
{

    $ = jQuery;

    var joinID = $(elem).attr("data-joinid");
    var substID = $(elem).attr("id");

    if (joinID == undefined || joinID == null || joinID == "")
        return false;

    var styleSheet = getStyleSheet("Highlights");

    var slider = document.getElementById("slider").slider;
    var knob = slider.knob;

    var startSession = sessions[knob.firstSelection];
    var endSession = sessions[knob.lastSelection];

    var session = elem.getAttribute("data-session");
    
    if (session >= startSession && session <= endSession)            
    {

        // TODO: now that we only highlight <add>s (not <del>s) maybe we can remove/simplify the _add suffix, the data-mode attribute, etc.
        
        addRemoveRule(on, styleSheet, 
            ".join_" + joinID + ".mode_add#" + substID,
            "color:white; background-color:#000000 !important");

        addRemoveRule(on, styleSheet, 
            ".join_" + joinID + ".mode_add",
            "color:black; background-color:#AAAAAA !important");

    } // if layer

    return true;
    
}

function hoverHighlight(on, elem)
{

    if (document.renderMode == "productMode" || document.renderMode == "readingMode")
        return;

    while (elem)
    {
        if (manageHighlightStyles(on, elem))
            break;
        elem = elem.parentElement;
        
    } // while elem
    
}

function OnPageChange(prevPage, newPage, zoomData)
{

    $ = jQuery;

    $("#yourImageID").smoothZoom("destroy").css("background-image", "url(zoom_assets/preloader.gif)").smoothZoom({
        width: "100%",
        height: "100%",
        responsive: true,
        animation_SPEED_ZOOM: 0.5,
        on_ZOOM_PAN_UPDATE: updatePolygonTransform,
        on_INIT_DONE: zoomData,
        image_url: "images/" + imageFilenames[newPage] + ".jpg"
    });
    
    showPolyPage(prevPage, false);
    showPolyPage(newPage, true);
    
    $(".text").css("color", "gray");
    $(".text.page" + newPage).css("color", "inherit");

    $(".pageNavHighlight").css("background-color", "#B0C4DE");
    $(".pageNavHighlight.page" + newPage).css("background-color", "#8094AE");

    $("#ZoomCtlAnchor").hide();
    $(".polygonPath.polygonContent").attr("class", "polygonPath polygonContent"); // TODO: this should be in polygons.js somewhere

}