jQuery.fn.PageCtl = function(numPages, OnPageChange)
{
    this.pageCtl = new PageCtl(this, numPages, OnPageChange);
    return this.pageCtl;
}

function PageCtl(elem, maxPage, onpagechange)
{
    elem.pageCtl = this;

    this.elem = elem;
    this.maxPage = maxPage;
    this.onpagechange = onpagechange;   
    this.curPage = -1;
    
    $(elem)
        .addClass("noSel")
        .css({ width: "135px", height: "26px", zIndex: 20 });
        
    $("<div></div>")
        .addClass("noSel controlsBg")
        .appendTo(elem);
            
    this.prevButton = CreateButton(elem, "idPrev", 4, 4, "-117px"); 
    CreateLabel(elem, "idPageLabel", 26, 4, 20, 18, "Page");
    this.pageEdit = CreateEdit(elem, "idPageCtl", 54, 4, 20, 14);
    this.nextButton = CreateButton(elem, "idNext", 114, 4, "-167px");
    CreateLabel(elem, "idPageLast", 80, 4, 30, 18, "of " + this.maxPage);
    
    this.SetPage(0);

}

PageCtl.prototype.OnMouseOver = function(event, on)
{

    if (event.target.id == "idPrev")
        this.prevHover = on;
    else if (event.target.id == "idNext")
        this.nextHover = on;
        
    this.SetButtonState();
    
}

PageCtl.prototype.OnClick = function(event)
{

    if (event.target.id == "idNext")
        delta = 1;
    else if (event.target.id == "idPrev")
        delta = -1;
        
    this.SetPage(this.GetPage() + delta);
}

PageCtl.prototype.SetPage = function(page, data)
{
    this.pageEdit.val(page+1);
    return this.NotifyPageChange(data);
}

PageCtl.prototype.NotifyPageChange = function(data)
{
    
    var page = Number(this.pageEdit.val())-1; 
    
    // bogus input
    if (isNaN(page) || page < 0 || page >= this.maxPage)
    {
        this.pageEdit.val(this.curPage+1)
        return;
    }
    
    // already on the right page
    if (page == this.curPage)
        return; 
    
    // set curPage to the requested page
    var prevPage = this.curPage;
    this.curPage = page;
    
    // enable/disable buttons as needed
    this.SetButtonState();

    // inform the caller that the page as changed
    if (this.onpagechange)
        this.onpagechange(prevPage, page, data);
        
}

PageCtl.prototype.GetPage = function()
{
    return this.curPage;
}

PageCtl.prototype.SetButtonState = function(hover)
{
    // 0.4 = diabled, 0.7 = enabled, 1.0 = hover
    this.prevButton.css("opacity", this.GetPage() <= 1 ? 0.4 : this.prevHover ? 1.0 : 0.7);
    this.nextButton.css("opacity", this.GetPage() >= this.maxPage ? 0.4 : this.nextHover ? 1.0 : 0.7);
}

function CreateButton(parent, id, left, top, icon)
{

    var button = $("<div></div>")
        .addClass("noSel controlsBtn")
        .css({
            left: left + "px",
            top: top + "px"
            })
        .appendTo(parent);

    var buttonBack = $("<div></div>")
        .css({
            background: "white",
            borderRadius: 2,
            left: "1px",
            top: "1px",
            width: "16px",
            height: "16px",
            position: "absolute",
            })
        .appendTo(button);

    var buttonIcon = $("<div></div>", { id: id })
        .css({
            background: "url('zoom_assets/icons.png') no-repeat " + icon + " -17px",
            left: "1px",
            top: "1px",
            width: "16px",
            height: "16px",
            position: "absolute",
            })
         .on({
            mouseover: function(event) { parent.pageCtl.OnMouseOver(event, true); },
            mouseout: function(event) { parent.pageCtl.OnMouseOver(event, false); },
            click: function(event) { parent.pageCtl.OnClick(event); },
            })
        .appendTo(button);

    return button;
}

function CreateLabel(parent, id, left, top, width, height, text)
{
    return $("<div></div>", { id: id })
        .addClass("noSel controlsTxt")
        .text(text)
        .css({
            left: left + "px",
            top: top + "px",
            width: width + "px",
            height: height + "px",
            color: "white",
            })
        .appendTo(parent);
}

function CreateEdit(parent, id, left, top, width, height)
{
    return $("<input></input>", { id:id, type: "text" })
        .addClass("controlsTxt")
        .css({
            left: left + "px",
            top: top + "px",
            width: width + "px",
            height: height + "px",
            color: "black",
            })
        .change(function() { parent.pageCtl.NotifyPageChange(); })
        .keyup(function(e) { if (e.keyCode == 13) parent.pageCtl.NotifyPageChange(); })
        .appendTo(parent);
}