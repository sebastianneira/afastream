sub init()
    m.top.focusable = true
    baseAddObservers()
end sub

function isSelectKey(key as String) as boolean
    return key = "OK" or key = "play"
end function

sub baseAddObservers()
    m.top.observeField("focusedChild","onFocus")
    m.top.observeField("enabled", "onEnabledChanged")
end sub

function onFocus(evt)
    ' Override to handle onFocus() in your component
end function

function onSelectableKeyPress(key,press) as boolean
    'Override to handle key press in extended component
    return false
end function

function onEnabledChanged(evt)
    m.top.opacity = iif(m.top.enabled, m.top.focusOnOpacity, m.top.notEnabledOpacity)
end function

function onKeyEvent(key, press) as boolean
    eventCaptured = onSelectableKeyPress(key,press)
    
    if eventCaptured or not press or not m.top.enabled then return eventCaptured

    if isSelectKey(key) 
        if m.top.keepSelection 
            if not m.top.selected then m.top.selected = true
        else
            m.top.selected = not m.top.selected
        end if
        eventCaptured = true
    end if

    return eventCaptured
end function
