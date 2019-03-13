function getStyleSheet(name)
{
    return jQuery("style#" + name)[0].sheet;
}

var normalizeSelector = [];

function addRule(styleSheet, selector, style)
{
    var i = styleSheet.insertRule(selector + "{ " + style + " }", styleSheet.cssRules.length);
    normalizeSelector[selector] = styleSheet.cssRules[i].selectorText;
}

function removeRule(styleSheet, selector)
{

    var normalizedSelector = normalizeSelector[selector];
    if (!normalizedSelector)
        normalizedSelector = selector;

    var rules = styleSheet.cssRules;

    for (i=rules.length-1; i>=0; i--)
    {
        if (rules[i].selectorText == normalizedSelector)
            styleSheet.deleteRule(i);
    }

}

function addRemoveRule(add, styleSheet, selector, style)
{
    if (add)
        addRule(styleSheet, selector, style);
    else
        removeRule(styleSheet, selector);
}
