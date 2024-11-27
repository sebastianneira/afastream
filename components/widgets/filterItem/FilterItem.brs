sub init()
    setComponents()
    addObservers()
    setStyles()
    initComponent()
end sub

sub setComponents()
    findNodes([
        "background"
        "label"
    ])
end sub

sub setStyles()
    m.textPadding = 15
   
    m.background.update({
        height: 45
        width: 99
        blendColor: m.top.color
        uri: "pkg:/images/10px-round-fhd.9.png"
    })

    m.label.update({
        horizAlign: "center"
        vertAlign: "center"
        height: m.background.height
        opacity: m.top.focusOffOpacity
        color: m.top.textColor
        translation: [m.textPadding,0]
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 24
        }
    })
end sub

sub initComponent()
    m.top.focusable = true
end sub

sub addObservers()
    m.top.observeField("selected", "onSelected")
    m.top.observeField("focusedChild", "onFocus")
    m.label.observeField("text", "onTextChanged")
end sub

sub onSelected(evt as dynamic)
    if m.top.isInFocusChain() then return
    
    if evt.getData()
        m.background.blendColor = m.top.selectedColor
        m.label.color = m.top.selectedTextColor
    else
        m.background.blendColor = m.top.color
        m.label.color = m.top.textColor
    end if
end sub

sub onTextChanged()
    m.background.width = m.label.boundingRect().width + (m.textPadding * 2)
end sub

sub onFocus()
    if m.top.isInFocusChain()
        m.background.blendColor = m.top.focusColor
        m.label.color = m.top.selectedTextColor
    else
        m.background.blendColor = iif(m.top.selected, m.top.selectedColor, m.top.color)
        m.label.color = iif(m.top.selected, m.top.selectedTextColor, m.top.textColor)
    end if
end sub