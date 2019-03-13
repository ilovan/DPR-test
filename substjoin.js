var highlightLocked = false;

function JoinHighlightReset()
{
    highlightLocked = false;
    JoinHighlight(undefined, false, false);
}

function JoinHighlight(elem, on, lock)
{

    if (highlightLocked && !lock)
        return;
        
    if (lock)
        highlightLocked = true;
    
    var styleSheet = getStyleSheet("JoinHighlights");
    var rules = styleSheet.cssRules;

    var i;
    for (i=rules.length-1; i>=0; i--)
    {
        if (styleSheet.removeRule) styleSheet.removeRule(i);
        else if (styleSheet.deleteRule) styleSheet.deleteRule(i);
    }
    
    if (on)
    {
        var id = $(elem).attr("data-joinid");
        addRule(styleSheet, ".joinMarkerID_"+id, "z-index:1; border-left-color:" + (lock ? "#000000" : "#777777") + " !important");
    }

}

function initSubstJoinHighlight()
{
    
    $(".join")
        .hover(function(event) { JoinHighlight(this, true, false); }, function() { JoinHighlight(this, false, false); })
        .click(function(event) { event.stopPropagation(); JoinHighlight(this, true, true); });

    $("body").click(JoinHighlightReset);

    createSubstJoinHighlightDivs();
    
}

function createSubstJoinHighlightDivs()
{

    var firstIndices = new Array();
    var lastIndices = new Array();
    
    var joins = $(".join").toArray();
    var i;
    
    var sessionFromId = [];
    
    for (i=0; i<joins.length; i++) 
    {
        var join = $(joins[i]);
        var id = join.attr("data-joinid");
        var session = join.attr("data-session");

        sessionFromId[id] = session;

        $("<div></div>")
            .addClass("joinMarkerType_Target")
            .addClass("joinMarkerID_" + id)
            .addClass("joinMarkerSession_" + session)
            .css("position", "absolute")
            .data("alignTopElement", join)
            .data("alignBottomElement", join)
            .appendTo("#substJoinBar");
    }

    for (i=0; i<joins.length; i++)
    {
        var id = $(joins[i]).attr("data-joinid");
        if (undefined == id)
            continue;
        if (undefined == firstIndices[id])
            firstIndices[id] = i;
    }

    for (i=joins.length; i>=0; i--)
    {
        var id = $(joins[i]).attr("data-joinid");    
        if (undefined == id)
            continue;
        if (undefined == lastIndices[id])
            lastIndices[id] = i;
    }

    for (var id in firstIndices)
    {
        var first = $(joins[firstIndices[id]]);
        var last = $(joins[lastIndices[id]]);
        var session = sessionFromId[id];
        
        $("<div></div>")
            .addClass("joinMarkerType_Span")
            .addClass("joinMarkerID_" + id)
            .addClass("joinMarkerSession_" + session)
            .css("position", "absolute")
            .data("alignTopElement", first)
            .data("alignBottomElement", last)
            .appendTo("#substJoinBar");
    }
    
/*---------------------------------------------------------------------------------*/

    // TODO: this stuff related to the page highlighting shouldn't be in substJoin.js
    $(".pageNavHighlight")
        .each(
            function() 
            { 
            
                var page = Number($(this).attr("data-page"));
                var textElems = $(".text.page" + page);
                
                $(this)
                    .css("border", "1px solid #8094AE")
                    .css("position", "abolute")
                    .data("alignTopElement", textElems.first())
                    .data("alignBottomElement", textElems.last())
                    .css("cursor", "pointer")
                    .click(function() { document.pageCtl.SetPage(page); });
            })

/*---------------------------------------------------------------------------------*/

    positionSubstJoinHighlightDivs();



}

var positionSubstJoinHighlightDivsLazy = _.debounce(function() { alignDivToElements("#substJoinBar"); alignDivToElements("#pageNavBar"); }, 500);

function positionSubstJoinHighlightDivs()
{
    $("#substJoinBar").children().stop().css({opacity: 0});
    $("#pageNavBar").children().stop().css({opacity: 0});
    positionSubstJoinHighlightDivsLazy();
}

function alignDivToElements_experimental(containerId)
{

    if ($(containerId).is(":hidden"))
       return;
 
    var elems = $(containerId).children();
    var i=0;
    
    var interval = setInterval(
        function()
            {
            
                var start = new Date();
                
                while (new Date() - start < 250)
                {
                
                    var elem = elems.eq(i);
                    var top = elem.data("alignTopElement");
                    var bottom = elem.data("alignBottomElement");
                    
                    var height = (bottom.position().top + bottom.height()) - top.position().top;
            
                    elem
                        .height(height)
                        .offset({ top: top.offset().top, left: elem.parent().position().left });
            
                    i++;
                    
                    if (i>=elems.length)
                    {
                        elems.stop().animate({opacity: 1});
                        clearInterval(interval);    
                    }
                }
                
            },
            0);    

}

function alignDivToElements(containerId)
{

    if ($(containerId).is(":hidden"))
       return;
 
    $(containerId).children().each(function(index) {
        
        var top = $(this).data("alignTopElement");
        var bottom = $(this).data("alignBottomElement");
        
        var height = (bottom.position().top + bottom.height()) - top.position().top;

        $(this)
            .height(height)
            .offset({ top: top.offset().top, left: $(this).parent().position().left });

    })
    .stop().animate({opacity: 1});

}