sub init()
    m.top.layoutDirection = "vert"
    m.keyAction = {
        "down" : focusNext
        "up": focusPrevious
    }
end sub
