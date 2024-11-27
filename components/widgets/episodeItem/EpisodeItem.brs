sub init()
    setComponents()
    addObservers()
    setStyles()
    initComponent()
end sub

sub setComponents()
    findNodes([
        "container"
        "content"
        "icon"
        "date"
        "episodeTitle"
        "duration"
        "progressBarBg"
        "progressBar"
        "border"
        "animation"
        "contentOpacityInterpolator"
        "containerColorInterpolator"
    ])
end sub

sub addObservers()
    m.top.observeField("episode", "onEpisodeDataChanged")
    m.top.observeField("timestamp", "onTimeStampChanged")
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("isEntitledToPlay", "onIsEntitledToPlayChanged")
end sub

sub setStyles()
    m.progressBarDefaultColor = "0x7BB7C7"
    m.progressBarFocusColor = "0xEA3323"
    
    m.container.update({
        width: m.top.width
        height: m.top.height
        color: "0x00000000"
    })

    m.icon.update({
        width: 30
        height: 30
        uri: "pkg:/images/icon-play.png"
        translation: [24, 21]
    })

    m.content.update({
        translation: [75, 24]
        itemSpacings: [21]
        layoutDirection: "horiz"
        opacity: 0.7
    })

    m.date.update({
        color: "0xFFFFFF"
        wrap: false
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 21
        }
        width: 180
    })

    m.episodeTitle.update({
        color: "0xFFFFFF"
        wrap: false
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 21
        }
        width: 1127
    })

    m.duration.update({
        color: "0xFFFFFF"
        wrap: false
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 21
        }
        width: 120
    })

    m.progressBarBg.update({
        width: 102
        height: 24
        color: "0x5C5C5C"
    })

    m.progressBar.update({
        width: 0
        color: m.progressBarDefaultColor
        height: m.progressBarBg.height
    })

    m.border.update({
        width: m.top.width
        height: 1
        color: "0xFFFFFF" 
        opacity: "0.5"
    })

    m.animation.update({
        repeat: false
        duration: 0.2 
        optional: true
    })

    m.contentOpacityInterpolator.update({
        key: [0.0, 1.0],
        keyValue: [m.content.opacity, 1],
        fieldToInterp: "content.opacity"
    })

    m.containerColorInterpolator.update({
        key: [0.0, 1.0],
        keyValue: [m.container.color, "0x222222"],
        fieldToInterp: "container.color"
    })
end sub

sub initComponent()
end sub

sub onFocusChanged()
    startAnimation(m.animation, not m.top.isInFocusChain())
    
    if m.top.isInFocusChain()
        m.progressBar.color = m.progressBarFocusColor
    else
        m.progressBar.color = m.progressBarDefaultColor
    end if
end sub

sub onEpisodeDataChanged(evt)
    content = evt.getData()

    m.date.text = content.airDateFormatted
    m.episodeTitle.text = content.title
    m.duration.text = content.runtime
    
    'reset value when episode data has changed
    'm.progressBar.width = 0
end sub

sub onTimeStampChanged(evt)
    timeStamp = evt.getData()
    duration = m.top?.episode?.runtimeSeconds

    if timeStamp <> invalid and duration <> invalid
        progress = (timeStamp * 100) / duration 
        m.progressBar.width = (progress * 100 / m.progressBarBg.width)
    else
        m.progressBar.width = 0
    end if
end sub

sub onIsEntitledToPlayChanged(evt)
    if evt.getData() = true
        m.icon.uri = "pkg:/images/icon-play.png"
    else
        m.icon.uri = "pkg:/images/icon-lock.png"
    end if
end sub