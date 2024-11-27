function init()
    m.top.focusable = true
    baseAddObservers()
end function

function onReady()
end function

function onDestroy()
    removeObservers()
end function

sub removeObservers()
end sub

sub onContentChanged(evt)
end sub

' /**
'  * Override to handle the styling of the component
'  */
sub setStyle()
    m.style = m.top.style
    initStyle()
end sub

' /**
'  * Override to handle any handling of styles after it's been set
'  */
sub initStyle()
    ' Override
end sub

function baseOnFocus(evt)
    ' if m.top.hasFocus() and not isNullOrEmpty(m.top.tts)
    '     fireTTS(m.top.tts, 0, m.top.flushSpeech)
    ' end if
end function

sub baseAddObservers()
    m.top.observeField("focusedChild", "baseOnFocus")
    m.top.observeField("focusedChild", "onFocus")
end sub

function onFocus(evt)
    ' Override to handle onFocus() in your component
end function

sub onComponentKeyPress(key, press) as boolean
    'Override to handle key press in extended component
    return false
end sub

function onKeyEvent(key, press) as boolean
    return onComponentKeyPress(key, press)
end function
