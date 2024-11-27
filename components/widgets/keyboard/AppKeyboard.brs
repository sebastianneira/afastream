function init()
    setComponents()
    addObservers()
    setStyles()

    m.top.focusable = true
end function

sub setComponents()
    findNodes([
        "container"
        "background"
        "keyboard"
        "additionalBtns"
        "showPassword"
    ])
    m.textEditBox = m.keyboard.textEditBox
end sub

sub addObservers()
    m.top.observeField("context", "onContextChanged")
    m.top.observeField("node", "onNodeChanged")
    m.top.observeField("visible", "onVisibleChanged")
    m.top.observeField("focusedChild", "onFocusChanged")
end sub

sub setStyles()
    m.keyboard.translation = [252, 30]

    m.background.update({ 
        color: "0x555555"
        width: 1920
        height: 510
    })

    m.additionalBtns.update({
        horizAlignment: "center"
        'translation: [960, m.keyboard.boundingRect().height + 60]
        'translation: [960, m.keyboard.boundingRect().height + 60]
    })

    m.container.translation = [0, 1080 - m.background.boundingRect().height]
end sub

sub onNodeChanged(evt)
    node = evt.getData()

    if node <> invalid
        m.textEditBox.secureMode = node.isSecureField = true and node.showPassword = false
    end if
end sub

sub onContextChanged(evt)
    text = getValue(m.top.context, "text", "")
    
    if not isNullOrEmpty(text)
        m.textEditBox.text = text
        
        m.textEditBox.cursorPosition = Len(text)
    
    end if
end sub

sub onVisibleChanged(evt)
    isVisible = evt.getData()

    if isVisible
        m.keyboard.observeField("text", "onKeyboardTextChanged")
    else
        m.keyboard.unobserveField("text")
        m.keyboard.text = ""
    end if
end sub

sub onKeyboardTextChanged(evt)
    if not m.top?.context?.text = evt.getData()
        ' shouldSecureText = m.top.node?.isSecureField = true and m.top?.node.showPassword = false
        ' if not shouldSecureText
        '     m.top.text = evt.getData()

        '     m.keyboard.unobserveField("text")
        '     m.keyboard.text = secureText(m.top.text)
        '     m.keyboard.observeField("text", "onKeyboardTextChanged")
        ' else
            m.top.text = evt.getData()
        'end if
    end if
end sub

sub onFocusChanged()
    if m.top.hasFocus() then focusNode(m.keyboard)
end sub

function onKeyEvent(key, press) as boolean
    eventCaptured = false

    if not press then return eventCaptured

    if key = "up" and m.additionalBtns.isInFocusChain()
        focusNode(m.keyboard)
    else if key = "down" and m.keyboard.isInFocusChain() and m.additionalBtns.getChildCount() > 0
        focusNode(m.additionalBtns)
    end if
end function
