sub init()
    m.top.layoutDirection = "horiz"
    m.keyAction = {
        "right" : focusNext
        "left": focusPrevious
    }
end sub
