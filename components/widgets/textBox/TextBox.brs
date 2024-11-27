sub init()
    setComponents()
    setStyles()
    addObservers()
    initComponent()
end sub

sub setComponents()
    findNodes([
        "container",
        "label",
        "background",
        "border"
    ])
end sub

sub addObservers()
    m.top.observeField("title", "onTitleChanged")
    m.top.observeField("text", "onTextChanged")
    m.top.observeField("hint", "onHintChanged")
    m.top.observeField("width", "onWidthChanged")
    m.top.observeField("height", "onHeightChanged")
    m.top.observeField("borderSize", "onBorderSizeChanged")
end sub

sub initComponent()
    m.top.focusable = false
end sub

sub setStyles()
    m.textMargin = 15
    m.hintColor = "0x888888"
    m.textcolor = "0xFFFFFF"
    m.bgFocusColor = "0x333333"
    m.bgDefaultColor = "0x444444"
    m.borderFocusColor = "0xCCCCCC"
    m.borderDefaultColor = "0x535353"

    m.container.update({
        itemSpacings: [12]
    })

    m.border.update({
        color: m.borderDefaultColor
    })

    m.background.update({
        color: m.bgDefaultColor
        translation: [m.top.borderSize, m.top.borderSize]
    })

    m.titleStyle = {
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 18
        }
        maxLines: 1
        color: m.textColor
    }

    m.label.update({
        horizAlign: "left"
        vertAlign: "center"
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 24
        }
        height: 45
        color: m.textColor
        translation: [m.textMargin, 0]
        text: m.top.hint
    })

    adjustWidth()
    adjustHeight()
end sub

sub adjustWidth()
    width = m.top.width

    m.border.update({
        width: width + m.top.borderSize * 2
    })

    m.background.update({
        width: width
    })

    m.label.update({
        width: width - m.textMargin
    })

    if isValid(m.title)
        m.title.update({
            width: width
        })
    end if
end sub

sub adjustHeight()
    height = m.top.height

    m.border.update({
        height: height
    })

    m.background.update({
        height: height - (m.top.borderSize * 2)
    })

    m.label.update({
        height: height
    })
end sub

sub onFocus()
    if m.top.isInFocusChain()
        m.background.color = m.bgFocusColor
        m.border.color = m.borderFocusColor
    else
        m.background.color = m.bgDefaultColor
        m.border.color = m.borderDefaultColor
    end if
end sub

sub onWidthChanged(evt)
    adjustWidth()
end sub

sub onHeightChanged(evt)
    adjustHeight()
end sub

sub onBorderSizeChanged(evt)
    adjustWidth()
end sub

sub onTitleChanged(evt)
    title = evt.getData()

    if not isEmpty(title)
        m.title = CreateObject("roSGNode", "Label")
        m.title.update(m.titleStyle)
        m.title.width = m.background.width
        m.title.text = title

        m.container.insertChild(m.title, 0)
    end if
end sub

sub onTextChanged(evt)
    text = evt.getData()

    if not isEmpty(text)
        m.label.update({
            text: text
            color: m.textcolor
        })
    end if
end sub

sub onHintChanged(evt)
    hintText = evt.getData()

    if isEmpty(m.label.text)
        m.label.update({
            text: hintText
            color: m.hintColor 
        })
    end if
end sub