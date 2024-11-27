function init()
    setComponents()
    addObservers()
    setStyle()
end function

sub setComponents()
    findNodes([
        "background"
        "text"
        "icon"
    ])
end sub

sub addObservers()
    m.top.observeField("text", "onTextChanged")
end sub

sub setStyle()
    m.textHorizPadding = 15
    m.backgroundDefWidth = 45
    m.background.update({
        width: m.backgroundDefWidth
        height: 27
        blendColor: "0x000000"
        uri: "pkg:/images/33px-round-fhd.9.png"
    })
    m.text.update({
        text: "",
        width: m.background.width 
        height: m.background.height
        horizAlign: "center"
        vertAlign: "center"
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Bold.ttf",
            "size": 18
        }
        color: "0xFFFFFF"
    })

    m.iconStyle = {
        width: 24
        height: 24
        uri: "pkg:/images/icon-lock.png"
    }
end sub

function setToFreeBadge()
    m.top.color = "0x28a745"
    m.background.width = m.backgroundDefWidth
    m.text.width = m.backgroundDefWidth
    m.top.text = ucase(tr("free"))
end function

function setToGCPBadge(showLockIcon = false)
    setIconVisibility(showLockIcon)
    m.top.color = "0x007bff"
    m.background.width = m.backgroundDefWidth
    m.text.width = m.backgroundDefWidth
    m.top.text = ucase(tr("gcp"))
end function

function setToLiveBadge()
    m.top.color = "0xEA3323"
    m.background.width = m.backgroundDefWidth
    m.text.width = m.backgroundDefWidth
    m.top.text = ucase(tr("live"))
end function

sub setIconVisibility(showIcon = true)
    if showIcon = true
        m.icon.update(m.iconStyle)
    else
        m.icon.update({
            width:0
            height:0
        })
    end if
end sub

sub onTextChanged(evt)
    width = m.text.boundingRect().width

    if not m.icon.visible 
        width = width + (m.textHorizPadding * 2)
        m.background.width = width
        m.text.width = width
    else
        m.text.width = width + (m.textHorizPadding * 2)
        m.icon.translation = [m.text.width - m.textHorizPadding, 0]
        m.background.width = width + m.icon.width + (m.textHorizPadding * 2)
    end if
end sub

