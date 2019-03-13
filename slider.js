jQuery.fn.Slider = function(sliderData)
{
    this.slider = new Slider(this.get(0), sliderData);
    document.slider = this.slider; // TODO: this global is yucky
}

function Knob(slider)
{
    var knob = this;

    this.PositionKnob = PositionKnob;
    this.LayoutKnob = LayoutKnob;
    this.Snap = Snap;
    this.SnapTo = SnapTo;
    this.SetSingleSelectMode = SetSingleSelectMode;
    
    this.singleSelectMode = false;
    
    this.OnMouseDown = OnMouseDown;
    this.OnMouseMove = OnMouseMove;
    this.OnMouseUp = OnMouseUp;
    this.OnDoubleClick = OnDoubleClick;
    
    this.centerHandle = document.createElement("span");
    this.centerHandle.className = "centerHandle";
    this.centerHandle.onmousedown = OnMouseDown;
    this.centerHandle.ondblclick = OnDoubleClick;
    this.centerHandle.knob = this;
    slider.parentElem.appendChild(this.centerHandle);


    /*
    // experimenting with jquery tooltips to try to get session description to show up
    $(this.centerHandle).tooltip(
    {
        content: function() { return "(" + this.innerText + ")"; },
        items: "div"
    });
    */

    this.leftHandle = document.createElement("span");
    this.leftHandle.className = "leftHandle";
    this.leftHandle.onmousedown = OnMouseDown;
    this.leftHandle.ondblclick = OnDoubleClick;
    this.leftHandle.knob = this;
    slider.parentElem.appendChild(this.leftHandle);

    this.rightHandle = document.createElement("span");
    this.rightHandle.className = "rightHandle";
    this.rightHandle.onmousedown = OnMouseDown;
    this.rightHandle.ondblclick = OnDoubleClick;
    this.rightHandle.knob = this;
    slider.parentElem.appendChild(this.rightHandle);

    var DragState =
        { 
            NotDragging : 0,
            ResizeLeft : 1, 
            Move : 2, 
            ResizeRight : 3
        };

    this.dragState = DragState.NotDragging;
    this.dragOffset = 0;
    
    this.slider = slider;

    function PositionKnob()
    {

        this.centerHandle.style.top = this.slider.parentElem.offsetTop - (this.centerHandle.offsetHeight - slider.parentElem.offsetHeight)/2 + "px";
        this.leftHandle.style.top = this.centerHandle.offsetTop + "px";
        this.rightHandle.style.top = this.centerHandle.offsetTop + "px";

    }
    
    function LayoutKnob(doCenter)
    {

        if (doCenter)
        {
            this.centerHandle.style.left = this.leftHandle.offsetLeft + "px";
            this.centerHandle.style.width = (this.rightHandle.offsetLeft - this.leftHandle.offsetLeft) + this.rightHandle.offsetWidth + "px";
        }
        else
        {
            this.leftHandle.style.left = this.centerHandle.offsetLeft + "px";
            this.rightHandle.style.left = this.centerHandle.offsetLeft + this.centerHandle.offsetWidth - this.rightHandle.offsetWidth + "px";            
        }

    }
            
    this.PositionKnob();
    this.LayoutKnob(false);
    this.SetSingleSelectMode(false);
    
    function OnMouseDown(e)
    {
    
        var event = e ? e : window.event;
        var elem = event.target ? event.target : event.srcElement;
        var knob = this.knob;
        
        if (knob.singleSelectMode)
            elem =  knob.centerHandle;
            
        if (elem == knob.centerHandle)
            knob.dragState = DragState.Move;
        else if (elem == knob.leftHandle)
            knob.dragState = DragState.ResizeLeft;
        else if (elem == knob.rightHandle)
            knob.dragState = DragState.ResizeRight;
        else
            return;
            
        knob.dragOffset = (elem.offsetLeft + elem.offsetWidth/2) - event.clientX;
        
        document.onmousemove = OnMouseMove;     
        document.onselectstart = function(){ return false };
        document.onmouseup = OnMouseUp;
        
    }
    
    function FindNearestChunk(chunks, position)
    {
        var bestIndex = 0;
        for (i=0; i<chunks.length; i++)
        {
            if (Math.abs(position - chunks[i]) < Math.abs(position - chunks[bestIndex]))
                bestIndex = i;
        }
        return bestIndex;
    }
    
    function SnapTo(start, end)
    {
    
        var chunks = this.slider.chunks;

        if (end >= chunks.length-1)
            return;

        if (start < 0)
            return;

        if (end < start)
            return;
            
        if (this.singleSelectMode && end > start)
            end = start;

        this.leftHandle.style.left = chunks[start] - this.leftHandle.offsetWidth/2 + "px"; 
        this.rightHandle.style.left = chunks[end+1] - this.rightHandle.offsetWidth/2 + "px";

        this.firstSelection = start;
        this.lastSelection = end;

        this.LayoutKnob(true); 
                
        applySessionFilter(this.firstSelection, this.lastSelection);        
        
        
    }
    
    function SetSingleSelectMode(singleSelect)
    {
        
        this.singleSelectMode = singleSelect;

        this.leftHandle.style.cursor = singleSelect ? "move" : "w-resize"
        this.rightHandle.style.cursor = singleSelect ? "move" : "w-resize"

        if (singleSelect)
            this.SnapTo(this.lastSelection, this.lastSelection);

        else
            this.SnapTo(0, this.slider.itemCount-1);

    }
    
    function Snap()
    {
        var chunks = this.slider.chunks;
        
        var leftHandlePositon = this.leftHandle.offsetLeft + this.leftHandle.offsetWidth/2;
        var rightHandlePositon = this.rightHandle.offsetLeft + this.rightHandle.offsetWidth/2;

        leftChunk = Math.min(FindNearestChunk(chunks, leftHandlePositon), chunks.length-2);
        rightChunk = Math.max(FindNearestChunk(chunks, rightHandlePositon), 1);
                    
        this.SnapTo(leftChunk, rightChunk-1); 
    }
    
    function OnMouseUp(e)
    {

        var event = e ? e : window.event;
        var knob = document.slider.knob;
        
        dragging = false;
        startDragX = 0;
        document.onmousemove = null;
        document.onmouseup = null;

        knob.Snap();
        
    }
    
    function OnMouseMove(e)
    {
        
        var event = e ? e : window.event;
        var knob = document.slider.knob;
        var elem;
            
        if (knob.dragState == DragState.Move)
            elem = knob.centerHandle;
        if (knob.dragState == DragState.ResizeLeft)
            elem = knob.leftHandle; 
        if (knob.dragState == DragState.ResizeRight)
            elem = knob.rightHandle; 
                
        var dragPosition = event.clientX + knob.dragOffset;
        var newPosition = dragPosition - elem.offsetWidth/2;
        
        if (knob.dragState == DragState.ResizeLeft && newPosition > knob.rightHandle.offsetLeft - 50)
            return;
        
        if (knob.dragState == DragState.ResizeRight && newPosition < knob.leftHandle.offsetLeft + 50)
            return;
        
        elem.style.left = newPosition + "px";

        knob.LayoutKnob(knob.dragState != DragState.Move);
    
    }

    function OnDoubleClick(e)
    {

        var event = e ? e : window.event;
        var elem = event.target ? event.target : event.srcElement;
        var knob = document.slider.knob;

        if (knob.singleSelectMode)
            return;
            
        if (elem == knob.leftHandle || elem == knob.centerHandle)
            knob.leftHandle.style.left = knob.slider.parentElem.offsetLeft + "px";

        if (elem == knob.rightHandle || elem == knob.centerHandle)
            knob.rightHandle.style.left = knob.slider.parentElem.offsetLeft + knob.slider.parentElem.offsetWidth + "px";
    
        knob.LayoutKnob(true);
        knob.Snap();
    }

}

function Slider(parentElem, items)
{

    jQuery("body").keydown(OnKeyDown);

    this.parentElem = parentElem;
    this.items = items;
    this.itemCount = items.length; 
    this.init = init;
    this.init();
    
    this.firstSelection = 0;
    this.lastSelection = this.items.length-1;
        
    this.parentElem.slider = this;
    
    this.parentElem.style.display = "table";
    this.parentElem.style.whiteSpace = "nowrap";
    
    function init()
    {

        this.chunks = new Array();
    
        var row;
        (row = document.createElement("div")).style.display = "table-row";
        parentElem.appendChild(row);
        
        for (i=0; i<this.items.length+2; i++)
        {
            isRealChunk = (i > 0 && i < this.items.length+1);

            cell = document.createElement("span");
            cell.className = isRealChunk? "sliderChunk" : "sliderSpacer";
                        
            if (isRealChunk)
            {
                var item = this.items[i-1];
                cell.style.backgroundColor = item.color;
                cell.innerHTML = item.label;
                cell.itemIndex = i-1;
                cell.onclick = OnClick;
                cell.title = item.description;
            }
            // TODO: tooltip isn't shown when slider is on top of chunk.
            // Possible idea: Implement tip manually. In timer callback temporarily set pointer-events:none then use elementFromPoint to get slider chunk and ask it for its description
            row.appendChild(cell);
            if (i > 0)
                this.chunks.push(cell.offsetLeft);
            
        }

        this.knob = new Knob(this);
        parentElem.style.display = "table";
        parentElem.style.width = parentElem.offsetWidth + "px";
    }
    
    function OnClick(e)
    {
    
        var event = e ? e : window.event;
        var elem = event.target ? event.target : event.srcElement;
        var slider = document.slider;
        var knob = slider.knob;
        
        knob.SnapTo(elem.itemIndex, elem.itemIndex);
    }
    
}

function OnKeyDown(event)
{

    var slider = document.slider;
    var knob = slider.knob;
        
    var leftArrow = (event.keyCode == 37);
    var rightArrow = (event.keyCode == 39);
    
    if (leftArrow || rightArrow)
    {
        delta = leftArrow ? -1 : +1;

        doStart = event.ctrlKey || !event.shiftKey;
        doEnd = event.shiftKey || !event.ctrlKey; 
    
        knob.SnapTo(knob.firstSelection + (doStart ? delta : 0), knob.lastSelection + (doEnd ? delta : 0));
    }
    
    else if (!event.ctrlKey && !event.shiftKey && !event.altKey)
    {
        
        var inputChar = String.fromCharCode(event.keyCode);

        var startSearch = 0;
        if (slider.items[knob.firstSelection].label.charAt(0) == inputChar)
        {
            if (knob.firstSelection == knob.lastSelection)
                startSearch = knob.firstSelection+1;
            else
                startSearch = knob.firstSelection;
        }

        for (i=0; i<slider.items.length; i++)
        {
            var j = (i + startSearch) % slider.items.length;
            if (inputChar == slider.items[j].label.charAt(0))
            {
               knob.SnapTo(j, j);
               return false;
            }
        }
    }
    return true;
    
}
