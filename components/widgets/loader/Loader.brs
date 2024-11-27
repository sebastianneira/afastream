function init()
    m.top.focusable = false
    setComponents()
    setStyle()
end function

sub setComponents()
    m.container = m.top.findNode("container")
    m.logo = m.top.findNode("logo")
    m.spinner = m.top.findNode("spinner")
    m.title = m.top.findNode("title")
    m.background = m.top.findNode("background")
end sub

sub setStyle()
    m.background.update({
        width: 1920
        height: 1080
        color: "0x000000"
        opacity: 0.4
    })
    m.container.update({
        horizAlignment: "center"
        translation: [960, 420]
        itemSpacings: [18]
    })
    m.spinner.update({
        uri: "pkg:/images/loader/icon.png"
    })
    m.title.update({
        text: tr("loading"),
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 33
        }
    })
end sub
