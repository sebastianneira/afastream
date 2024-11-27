sub init()
    setComponents()
    addObservers()
    initComponent()
    setStyle()
end sub

sub initComponent()
end sub

sub setComponents()
    findNodes([
        "background"
        "overlay"
        "logo"
        "textContainer"
        "title"
        "description"
        "buttons"
        "btnCTA"
        "btnMoreInfo"
    ])
end sub

sub setStyle()
    m.liveBadgeStyle = {
        translation: [129,60]
    }
    
    m.background.update({
        width: 1624
        height: 510
        loadWidth: 1624
        loadDisplayMode: "scaleToZoom"
    })

    m.overlay.update({
        width: 1624
        height: 510
        uri: "pkg:/images/hero_tile_overlay.png"
    })

    m.logo.update({
        translation: [891, 0]
        loadWidth: 542
        loadHeight: 542
        loadDisplayMode: "limitSize"
        visible: false
    })

    m.textContainer.update({
        translation: [129, 120] 
        itemSpacings: [24, 36]
    })

    m.title.update({
        width: 600
        color: "0xFFFFFF"
        maxLines: 1
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 24
        }
    })
    m.description.update({
        width: 720
        color: "0xFFFFFF"
        maxLines: 4
        wrap: true
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Light.ttf",
            "size": 21
        }
    })

    m.buttons.update({
        keyHoldAllowed: false
        itemSpacings: [30]
    })

    m.btnMoreInfo.text = ucase(tr("more_info"))
end sub

sub addObservers()
    m.top.observeField("focusedChild", "onFocus")
    m.logo.observeField("bitmapHeight", "onBitMapHeightChanged")
    m.background.observeField("loadStatus", "onBgloadStatusChanged")
    m.btnCTA.observeField("selected", "onCTASelected")
    m.btnMoreInfo.observeField("selected", "onMoreInfoSelected")
end sub

sub createWatchListButton()
    watchListItems = m.global.userStateManager.callFunc("getWatchList")
    m.isInWatchList = watchListItems[m.top?.itemContent?.videoId.toStr()] <> invalid
    
    m.btnWatchList = m.buttons.createChild("Button")
    m.btnWatchList.update({
        icon: getWatchListIcon()
        text: ucase(tr("watch_list"))
    })
    m.btnWatchList.observeField("selected", "onBtnWatchlistSelected")
end sub

sub itemContentChanged(evt)
    m.top.unobserveField("itemContent")

    content = evt.getData()
    bgUri = ""
    overlayUri = ""

    if not isNullOrEmpty(content.backgroundImage)
        bgUri = m.global.environmentUrl + content.backgroundImage + "?width=" + m.background.width.toStr()
    end if

    if not isNullOrEmpty(content.overlayImage)
        overlayUri = m.global.environmentUrl + content.overlayImage
    end if
    
    m.background.uri = bgUri
    m.logo.uri = overlayUri
    m.title.text = content.heading
    m.description.text = content.content

    if content.isLive = true
        m.btnCTA.text = ucase(tr("watch_live"))
        badge = m.background.createChild("Badge")
        badge.callFunc("setToLiveBadge")
        badge.update(m.liveBadgeStyle)
    else
        m.btnCTA.text = ucase(tr("watch_now"))
        createWatchListButton()
    end if

    'if m.top.itemContent.videoId <> invalid then m.top.itemContent.id = m.top.itemContent.videoId
end sub

sub onFocus()
    if m.top.isInFocusChain()
        focusNode(m.buttons)
    end if
end sub

sub onBitMapHeightChanged(evt)
    height = evt.getData()
   
    if height > 0
        if height > m.background.height 
            m.logo.height = m.background.height
        else
            m.logo.translation = [m.logo.translation[0], (m.background.height - height)/2]
        end if
        
        m.logo.visible = true
    end if
end sub

sub onBgloadStatusChanged(evt)
    status = evt.getData()

    if status = "ready" or status = "failed"
        m.top.ready = true
    end if
end sub

sub onBtnWatchlistSelected()
    id = m.top.itemContent.videoId

    if id <> invalid
        if m.isInWatchList
            m.global.userStateManager.callFunc("removeFromWatchList", id)
        else
            m.global.userStateManager.callFunc("addToWatchList", id)
        end if
    end if

    m.isInWatchList = not m.isInWatchList
    m.btnWatchList.icon = getWatchListIcon()
end sub

sub onCTASelected()
    m.top.itemContent.update({ instantPlay: true}, true)
    m.top.selected = true
end sub

sub onMoreInfoSelected()
    m.top.itemContent.update({ instantPlay: false}, true)
    m.top.selected = true
end sub