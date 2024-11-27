sub init()
    setComponents()
    addObservers()
    initStyle()
end sub

sub setComponents()
    findNodes([
        "title"
        "underline"
    ])
end sub

sub addObservers()
    m.top.observeField("text", "onTitleChanged")
end sub

sub removeObservers()
end sub

sub initStyle()
    m.title.update({
        height: 39
        color: "0xFFFFFF"
        maxLines: 1
        vertAlign: "center"
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 24
        }
    })

    m.underline.update({
        height: 3
        width: 9
        color: m.title.color
        visible: false
        translation: [0, 39]
    })
end sub

sub onFocus(evt)
    m.underline.visible = m.top.hasFocus()
end sub

sub onTitleChanged(evt)
    width = m.title.boundingRect().width
    m.underline.width = width
end sub
