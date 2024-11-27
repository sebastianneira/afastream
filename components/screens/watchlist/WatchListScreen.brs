function init() as void
    setComponents()
    setStyles()
    addObservers()
    initComponent()
end function

sub setComponents()
    findNodes([
        "content"
        "backgroundOne"
        "backgroundTwo"
        "panel"
        "rowWatchList"
        "emptyWatchListLbl"
        "loadAnimation"
        "bgOpacityInterpolatorSelected"
        "bgOpacityInterpolatorUnselected"
    ])
end sub

sub setStyles()
    rowListStyle = copyAssocArray(m.config.styles.defaultRowList)
    backgroundStyle = {
        width: 1920
        height: 1080
        opacity: 1
    }

    m.backgroundOne.update(backgroundStyle)
    m.backgroundTwo.update(backgroundStyle)

    m.content.opacity = 0

    m.panel.update({
        width: 1920
        height: 420
        translation: [0, 660]
        color: "0x222121"
    })

    rowListStyle.numRows = 1
    rowListStyle.translation = [150, 30]
    m.rowWatchList.update(rowListStyle)
    
    m.emptyWatchListLbl.update({
        text: tr("empty_watchlist")
        width: 1920
        height: 1080
        maxLines: 1
        horizAlign: "center"
        vertAlign: "center"
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 48
        }
        color: "0xCCCCCC"
        visible: false
    })

    m.loadAnimation.update({
        duration: 1,
        optional: true
    })

    m.bgOpacityInterpolatorSelected.update({
        key: [0.0, 1.0],
        keyValue: [0.0, 1.0]
    })

    m.bgOpacityInterpolatorUnselected.update({
        key: [1.0, 0.0],
        keyValue: [0.0, 1.0]
    })

    m.screenOpacityInterpolator.fieldToInterp = "content.opacity"
end sub

sub addObservers()
    m.rowWatchList.observeField("itemSelected", "onGridItemSelected")
    m.rowWatchList.observeField("rowItemFocused", "onGridItemFocused")
    m.backgroundOne.observeField("loadStatus", "onBgloadStatusChanged")
    m.backgroundTwo.observeField("loadStatus", "onBgloadStatusChanged")
end sub

sub initComponent()
    m.showScreenEvent = "searchReadyAppEvent"
    m.selectedBackground = m.backgroundOne
    m.unSelectedBackground = m.backgroundTwo
end sub

sub onScreenInit()
    watchList = m.global.userStateManager.callFunc("getWatchList")

    if watchList.getChildCount() > 0
        isScreenLoading()
        showWatchList(watchList)
        m.emptyWatchListLbl.visible = false
    else
        m.emptyWatchListLbl.visible = true
    end if
end sub

sub showScreen()
    isScreenLoading(false)
    focusNode(m.rowWatchList)
    startAnimation(m.screenAnimation)
end sub

sub showWatchList(watchList)
    content = createObject("roSGNode", "ContentNode")
    content.appendChild(watchList)
    watchList.title = tr("watchlist")

    trackedChild = getChildByIndexOrLastNode(watchList, 4)
    if trackedChild <> invalid
        trackedChild.update({ trackLoadStatusEvent: m.showScreenEvent}, true)
    end if
    
    m.rowWatchList.content = content
end sub

sub showItemBackground(item)
    if item <> invalid and item.wideImageUrl <> m.prevFocusedItem?.wideImageUrl and not isEmpty(item.wideImageUrl)
        bgUri = m.global.environmentUrl + item.wideImageUrl

        m.bgOpacityInterpolatorSelected.fieldToInterp = m.selectedBackground.id + ".opacity"
        m.bgOpacityInterpolatorUnselected.fieldToInterp = m.unSelectedBackground.id + ".opacity"
        
        if m.selectedBackground.uri <> bgUri
            m.selectedBackground.uri = bgUri
        else
            showNextBackground()
        end if

        m.prevFocusedItem = item
    end if
end sub

sub showNextBackground()
    completeAnimation(m.loadAnimation)
    startAnimation(m.loadAnimation)

    swapSelectedBackground()
end sub

function swapSelectedBackground()
    if m.selectedBackground.id = m.backgroundOne.id
        m.selectedBackground = m.backgroundTwo
        m.unSelectedBackground = m.backgroundOne
    else
        m.selectedBackground = m.backgroundOne
        m.unSelectedBackground = m.backgroundTwo
    end if
end function

sub onScreenFocusChanged(evt)
    if m.top.hasFocus()
        focusNode(m.rowWatchList)
    end if
end sub

sub onScreenRevisit()
    focusNode(m.rowWatchList)
end sub

sub onGridItemFocused(evt)
    itemCords = evt.getData()

    if itemCords = invalid then return

    focusedItem = m.rowWatchList?.content?.getChild(itemCords[0])?.getChild(itemCords[1])
    showItemBackground(focusedItem)
end sub

sub onGridItemSelected(evt)
    row = evt.getRoSGNode()
    content = row.content
    rowItemSelected = row.rowItemSelected

    if content <> invalid and rowItemSelected.count() > 1
        item = content?.getChild(rowItemSelected[0])?.getChild(rowItemSelected[1])
        if isValid(item)
            navigate("DetailScreen", item)
        end if
    end if
end sub

sub onBgloadStatusChanged(evt)
    status = evt.getData()

    if status = "ready" or status = "failed"
        if m.content.opacity = 0
            showScreen()
        else
            showNextBackground()
        end if
    end if
end sub

sub onAppEvent(evt)
    event = evt.getData()
    
    if event?.name = m.showScreenEvent
        if m.rowWatchList.content <> invalid and m.rowWatchList.content.getChildCount() > 0
            firstItem = m.rowWatchList?.content?.getChild(0)?.getChild(0)
            if firstItem <> invalid
                showItemBackground(firstItem)
            end if

            showScreen()
        end if
    end if
end sub