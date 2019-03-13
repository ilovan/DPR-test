function highlightPolygon(on, elem, idList, action)
{

    var ids;

    if (document.renderMode != "processMode")
        return;

    showPolyForPage(on, document.pageCtl.GetPage(), idList, action);

    if (on)
    {
        configureZoomCtl(elem, idList, action);
    }
    else
    {
        $("#ZoomCtl").zoomCtl("fade");        
    }
 
}

function updatePolygonTransform(zoomData, animationComplete)
{

    var svg = $("#svg_pages").get(0);

    svg.setAttribute("transform", 
        "translate(" + (-zoomData.scaledX) + ", " + (-zoomData.scaledY) + ") " +
        "scale(" + (zoomData.scaledWidth/1000.0) + ", " + (zoomData.scaledHeight/1000.0) + ")");

}

var lastZoomCode = undefined;
function zoomToPolyOnPage(zoomIn, newPage, idList)
{

    var zoomData = $('#yourImageID').smoothZoom('getZoomData');

    if (!zoomIn)
    {
    
        $("#yourImageID")
            .smoothZoom('focusTo',{
                   x: zoomData.centerX,
                   y: zoomData.centerY,
                   zoom: 1,
                   speed: 6
            });

        return;
    }
        
    var ids;
    if (idList.trim() == "")
        ids = [];
    else
        ids = idList.split(/ +/);

    var x;
    var y;
    var zoom;
    
    function GetZoomCode(page, idList) { return "" + page + ": " + idList; }
    var first = !(GetZoomCode(newPage, idList) == lastZoomCode);
    lastZoomCode = GetZoomCode(newPage, idList);

    var zoomLeft = Number.MAX_VALUE;
    var zoomTop = Number.MAX_VALUE;
    var zoomRight = Number.MIN_VALUE;
    var zoomBottom = Number.MIN_VALUE;

    
    var i;
    for (i=0; i<ids.length; i++)
    {

        var id = ids[i];
        if (!polygonPages[id]) // TODO: needed?
            continue;
            
        var page = polygonPages[id].page;

        // skip polygons not on this page
        if (page != newPage)
            continue;

        // add it to the bounding box we're accumulating
        zoomLeft = Math.min(zoomLeft, polygonPages[id].left);        
        zoomTop = Math.min(zoomTop, polygonPages[id].top);        
        zoomRight = Math.max(zoomRight, polygonPages[id].right);        
        zoomBottom = Math.max(zoomBottom, polygonPages[id].bottom);        

    }

    var zoomWidth = zoomRight - zoomLeft;
    var zoomHeight = zoomBottom - zoomTop;
    
    // convert from 0-1000 range into actual source pixels
    function ScaleX(x) { return (x / 1000) * zoomData.normWidth; }
    function ScaleY(y) { return (y / 1000) * zoomData.normHeight; }

    // how big is the picture
    var pictureCtlWidth = $('#yourImageID').width();
    var pictureCtlHeight = $('#yourImageID').height();

    var zoomX = Math.floor(pictureCtlWidth*100 / ScaleX(zoomWidth));
    var zoomY = Math.floor(pictureCtlHeight*100 / ScaleY(zoomHeight));
    var zoom = Math.min(zoomX, zoomY) / 4; 

    if (!first)
        while (zoom < zoomData.ratio*100+5)
            zoom *= 2;

    x = ScaleX((zoomLeft + zoomRight) / 2);
    y = ScaleY((zoomTop + zoomBottom) / 2);

    $("#yourImageID")
        .smoothZoom('focusTo',{
               x: x,
               y: y,
               zoom: zoom,
               speed: 6
        });

}


// TODO: stupid helpers function to work around lack of SVG class support in jquery
function removeClass(s, c)
{
    if (s == undefined)
        s = "";
    return s.split(" ").filter(function(e) { return e != c; }).join(" ");
}

function addClass(s, c)
{
    if (s == undefined)
        s = "";
    var arr = s.split(" ");
    if (arr.indexOf(c) != -1)
        return s;
    return arr.concat([c]).join(" ");
}

function showPolyForPage(on, newPage, idList, action)
{

    var ids;

    if (idList.trim() == "")
        ids = [];
    else
        ids = idList.split(/ +/);        

    var i;
    for (i=0; i<ids.length; i++)
    {

        var id = ids[i];
        if (!polygonPages[id]) // TODO: needed?
            continue;

        var page = polygonPages[id].page;

        // skip polygons not on this page
        if (page != newPage)
            continue;
        
        var $path = $("#" + id + " > .polygonContent");

        $path.attr("class", (on ? addClass : removeClass)($path.attr("class"), action));
                        
    }
    
} // showPolyForPage


function configureZoomCtl(elem, idList, action)
{

    var ids;
    if (idList.trim() == "")
        ids = [];
    else
        ids = idList.split(/ +/);

    var currPage = document.pageCtl.GetPage();
    var foundCurr = false;
    var firstPage = Number.POSITIVE_INFINITY;
    var prevPage = Number.NEGATIVE_INFINITY;
    var nextPage = Number.POSITIVE_INFINITY;
    
    var i;
    for (i=0; i<ids.length; i++)
    {
    
        if (!polygonPages[ids[i]]) // TODO: needed?
            continue;
        
        var page = polygonPages[ids[i]].page;
        
        firstPage = Math.min(firstPage, page);
        
        if (page == currPage)
            foundCurr = true;
            
        else if (page < currPage)
            prevPage = Math.max(prevPage, page);
            
        else if (page > currPage)
            nextPage = Math.min(nextPage, page);

    } // for id

    var foundPrev = (prevPage != Number.NEGATIVE_INFINITY);
    var foundNext = (nextPage != Number.POSITIVE_INFINITY);

    if (!foundPrev && !foundCurr && !foundNext)
    {
        $("#ZoomCtlAnchor")
            .appendTo(document.body)
            .hide();
        return;
    }

    var fnGoto = !foundCurr && firstPage != Number.POSITIVE_INFINITY ?
        function()
        {
            document.pageCtl.SetPage(firstPage, function () { showPolyForPage(true, prevPage, idList, action); configureZoomCtl(elem, idList, action); });
        }
        : false;
        

    var fnPrev = !fnGoto && foundPrev ?
        function()
        {
            document.pageCtl.SetPage(prevPage, function () { showPolyForPage(true, prevPage, idList, action); configureZoomCtl(elem, idList, action); });
        }
        : false;

    var fnZoomOut = foundCurr ?
        function()
        {
            zoomToPolyOnPage(false, currPage, idList);
        }
        : false;

    var fnZoomIn = foundCurr ?
        function()
        {
            zoomToPolyOnPage(true, currPage, idList);
        }
        : false;

    var fnNext = !fnGoto && foundNext ?
        function()
        {
            document.pageCtl.SetPage(nextPage, function () { showPolyForPage(true, nextPage, idList, action); configureZoomCtl(elem, idList, action); });                    
        }
        : false;

    if (elem)
    {
        $("#ZoomCtlAnchor")
            .appendTo(elem)
            .show()
            .position(
                {
                    my: "left center",
                    at: "right center",
                    of: elem
                });
    }
     
    $("#ZoomCtl")
        .zoomCtl(
            {
                onGoto: fnGoto,
                onPrev: fnPrev,
                onZoomOut: fnZoomOut,
                onZoomIn: fnZoomIn,
                onNext: fnNext
            });

}

function configureZoomCtl_OLD(elem, idList, action)
{

    var ids;
    if (idList.trim() == "")
        ids = [];
    else
        ids = idList.split(/ +/);

    var currPage = document.pageCtl.GetPage();
    var foundCurr = false;
    var prevPage = Number.NEGATIVE_INFINITY;
    var nextPage = Number.POSITIVE_INFINITY;
    
    var i;
    for (i=0; i<ids.length; i++)
    {
    
        if (!polygonPages[ids[i]]) // TODO: needed?
            continue;
        
        var page = polygonPages[ids[i]].page;
        
        if (page == currPage)
            foundCurr = true;
            
        else if (page < currPage)
            prevPage = Math.max(prevPage, page);
            
        else if (page > currPage)
            nextPage = Math.min(nextPage, page);

    } // for id

    var foundPrev = (prevPage != Number.NEGATIVE_INFINITY);
    var foundNext = (nextPage != Number.POSITIVE_INFINITY);

    if (!foundPrev && !foundCurr && !foundNext)
    {
        $("#ZoomCtlAnchor")
            .appendTo(document.body)
            .hide();
        return;
    }

    var fnPrev = !foundPrev ? false :
        function()
        {
            document.pageCtl.SetPage(prevPage, function () { showPolyForPage(true, prevPage, idList, action); configureZoomCtl(elem, idList, action); });
        };

    var fnPrev = !foundPrev ? false :
        function()
        {
            document.pageCtl.SetPage(prevPage, function () { showPolyForPage(true, prevPage, idList, action); configureZoomCtl(elem, idList, action); });
        };

    var fnZoomOut = 
        function()
        {
            zoomToPolyOnPage(false, currPage, idList);
        };

    var fnZoomIn = !foundCurr ? false :
        function()
        {
            zoomToPolyOnPage(true, currPage, idList);
        };

    var fnNext = !foundNext ? false :
        function()
        {
            document.pageCtl.SetPage(nextPage, function () { showPolyForPage(true, nextPage, idList, action); configureZoomCtl(elem, idList, action); });                    
        };

    if (elem)
    {
        $("#ZoomCtlAnchor")
            .appendTo(elem)
            .show()
            .position(
                {
                    my: "left center",
                    at: "right center",
                    of: elem
                });
    }
     
    $("#ZoomCtl")
        .zoomCtl(
            {
                onGoto: fnGoto,
                onPrev: fnPrev,
                onZoomOut: fnZoomOut,
                onZoomIn: fnZoomIn,
                onNext: fnNext
            });

}

function showPolyPage(page, on)
{    
    var $page = $("#svg_page_" + page);
    $page.attr("class", (on ? addClass : removeClass)($page.attr("class"), "polygonPageShow"));

}

function showAllPolyOnPage(page, on)
{
    var $page = $("#svg_page_" + page);
    $page.attr("class", (on ? addClass : removeClass)($page.attr("class"), "polygonPageShowHint"));
}