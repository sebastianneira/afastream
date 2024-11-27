sub init()
    setComponents()
    addObservers()
    addStyles()
    initComponent()
end sub

sub setComponents()
    findNodes([
        "background"
        "icon"
        "label"
        "animation"
        "iconOpacityInterpolator"
    ])
end sub

sub addStyles()
    m.background.update({
        uri: "pkg:/images/5px-empty-fhd.9.png"
        blendColor: "0xFFFFFF" 
    })

    m.icon.update({
        width: 45
        height: 45
        uri: "pkg:/images/menu/search.png" 
        translation: [18,12]
        opacity: 0.8
        blendColor: "0xABABAB"
    })

    m.label.update({
        horizAlign: "left"
        vertAlign: "center"
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 33
        }
        translation: [75,0]
        color: "0xFFFFFF"
    })

    m.animation.update({
        duration: "1.5",
        repeat: true,
        optional: true
    })

    m.iconOpacityInterpolator.update({
        key: [0.0, 0.5, 1.0],
        keyValue: [0.7, 1.0, 0.7],
        fieldToInterp: "icon.opacity"
    })
end sub

sub initComponent()
    setFocusState(false)
end sub

sub addObservers()
    m.top.observeField("text", "onTextChanged")
    m.top.observeField("hint", "onTextChanged")
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("width", "onWidthChanged")
    m.top.observeField("height", "onHeightChanged")
end sub

sub setFocusState(hasFocus as Boolean)
    if hasFocus
        m.top.opacity = m.top.focusOnOpacity
    else
        m.top.opacity = m.top.focusOffOpacity
    end if
end sub

sub onTextChanged(evt as Dynamic)
    text = evt.getData()

    if isNullOrEmpty(text) then text = m.top.hint
    m.label.text = text
end sub


sub onFocusChanged()
    setFocusState(m.top.hasFocus())
    
    if m.top.hasFocus()
        startAnimation(m.animation)
    else
        completeAnimation(m.animation)
    end if
end sub

sub onWidthChanged(evt as Dynamic)
    width = evt.getData()

    m.background.width = width
end sub

sub onHeightChanged(evt as Dynamic)
    height = evt.getData()

    m.background.height = height
    m.label.height = height
end sub