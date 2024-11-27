sub init()
    homeTile_setComponents()
    homeTile_setStyle()
end sub

sub homeTile_setComponents()
    findNodes([
        "background"
        "label"
        "image"
        "progressBar"
        "progress"
        "badge"
    ])
end sub

sub homeTile_setStyle()
    m.imageWidth = 210
    m.imageHeight = 300

    m.background.update({
        width: m.imageWidth
        height: m.imageHeight
        color: "0x333333"
    })

    m.label.update({
        width: m.imageWidth
        height: m.imageHeight
        horizAlign: "center"
        vertAlign: "center"
        text: tr("see_all")
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 24
        }
        color: "0xCCCCCC"
        visible: false
    })

    m.image.update({
        width: m.imageWidth
        height: m.imageHeight
        loadHeight: m.imageHeight
        loadWidth: m.imageWidth
        loadDisplayMode: "limitSize"
        failedBitmapUri: "pkg:/images/default-home-tile-image.png"
        loadingBitmapUri: "pkg:/images/default-home-tile-image.png"
    })

    m.progressBar.update({
        background: "0x007bff"
        height: 6
        width: m.imageWidth
        opacity: 0.75
        translation: [0, m.imageHeight - 6]
    })

    m.progress.update({
        color: "0x007bff"
        width: 0
        height: 6
    })

    m.badge.update({ 
        translation: [6,9] 
    })
end sub

sub setupHomeTile(evt)
    content = evt.getData()
    badge = invalid

    if content.showAllItems = true
        m.image.visible = false
        m.label.visible = true

        return
    else
        m.label.visible = false
        m.image.visible = true
    end if

    m.image.uri = m.global.environmentUrl + content.imageUrl + "?width=" + m.imageWidth.toStr()
    
    'Progress
    if content.session <> invalid
        timeStamp = content?.session?.timeStamp
        duration = content?.episode?.runtimeSeconds

        if timeStamp > 0
            if duration <> invalid and timeStamp <> invalid
                progress = (timeStamp * 100) / duration 
                m.progress.width = (progress * 100 / m.progressBar.width)
            end if
        end if
    else
        m.progressBar.visible = false
    end if
    
    'Badge
    if content.isGCP = true
        isEntitledToPlay = m.global?.userStateManager?.user?.profile.isGCP
        m.badge.callFunc("setToGCPBadge", not isEntitledToPlay)
    else
        m.badge.callFunc("setToFreeBadge")
    end if

    'Load tracking
    if content.trackLoadStatusEvent <> invalid
        m.tmrLoading = CreateObject("roSGNode", "Timer")
        m.tmrLoading.duration = iif(content.timeOutSeconds <> invalid, content.timeOutSeconds, 5)
        
        m.image.observeField("loadStatus", "onBgloadStatusChanged")
        m.tmrLoading.observeField("fire", "onTmrLoadingFired")

        m.tmrLoading.control = "start"
    end if

    m.image.appendChild(badge)
end sub

sub itemContentChanged(evt)
    setupHomeTile(evt)
end sub

sub onBgloadStatusChanged(evt)
    status = evt.getData()

    if status = "ready" or status = "failed"
        if m.top.itemContent.trackLoadStatusEvent <> invalid
            scene = m.top.getScene()
            scene.appEvent = { name: m.top.itemContent.trackLoadStatusEvent, value: status }
            m.tmrLoading.control = "stop"
        end if
    end if
end sub

sub onTmrLoadingFired()
    if m.top.itemContent.trackLoadStatusEvent <> invalid
        scene = m.top.getScene()
        scene.appEvent = { name: m.top.itemContent.trackLoadStatusEvent, value: "ready" }
    end if
end sub