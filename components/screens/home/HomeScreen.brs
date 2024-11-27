function init() as void
    setComponents()
    addObservers()
    setStyles()
    initComponent()
end function

function setComponents()
    findNodes([
        "scroller"
        "loadAnimation"
        "bgOpacityInterpolator"
    ])

    m.scrollerContainer = m.scroller.findNode("container")
    m.carousel = m.scrollerContainer.createChild("carousel")
end function

function addObservers()
    m.carousel.observeField("ready", "onCarouselReady")
    m.carousel.observeField("selectedItem", "onCarouselItemSelected")
    m.global.liveStreamsManager.observeField("liveStreamShow", "onLiveShowChanged")
end function

function setStyles()
    m.scroller.update({
        itemSpacings: [21]
        translation: [99, 0]
        opacity: 0
    })

    m.screenOpacityInterpolator.fieldToInterp = "scroller.opacity"
end function

function getRowListStyle(hasTemplate = false)
    rowListStyle = copyAssocArray(m.config.styles.defaultRowList)

    if hasTemplate
        rowListStyle.itemComponentName = "HomeTileLarge"
        rowListStyle.rowItemSize = [[210, 420]]
        rowListStyle.itemSize = [1374, 450]
    end if

    rowListStyle.translation = [99, 0]

    return rowListStyle
end function

sub initComponent()
    m.showScreenEvent = "ContinueWatchingReady"
    m.screenInitialized = false
    m.itemsPerRow = 6
end sub

function onScreenInit() as void
    loadSlides()
    isScreenLoading(true)
    fireAppLaunchComplete()
end function

function loadSlides()
    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        path: "video/slides"
        method: "POST"
        body: {
            "includeAll": true
        }
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.request = requestContext.callFunc("getRequest")
    requestNode.observeFieldScoped("response", "onGetSlides")

    m.httpTask.requests = [requestNode]
end function

function loadContinueWatching()
    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        path: "video/continuewatching"
        method: "POST"
        body: {
            "take": 10,
            "page": 0
        }
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.request = requestContext.callFunc("getRequest")
    requestNode.observeFieldScoped("response", "onGetContinueWatching")
    m.httpTask.requests = [requestNode]
end function

function loadNewReleases()
    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        path: "video/newvideos"
        method: "POST"
        body: {
            "take": 10
            "page": 0
            "includeAll": true
        }
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.request = requestContext.callFunc("getRequest")
    requestNode.observeFieldScoped("response", "onGetNewReleases")
    m.httpTask.requests = [requestNode]
end function

function loadNewEpisodes()
    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        path: "video/newepisodes"
        method: "POST"
        body: {
            "includeAll": true
        }
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.request = requestContext.callFunc("getRequest")
    requestNode.observeFieldScoped("response", "onGetNewEpisodes")
    m.httpTask.requests = [requestNode]
end function

function loadPopularVideos()
    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        path: "video/popularvideos"
        method: "POST"
        body: {
            "includeAll": true
        }
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.request = requestContext.callFunc("getRequest")
    requestNode.observeFieldScoped("response", "onGetPopularVideos")
    m.httpTask.requests = [requestNode]
end function

sub onGetSlides(evt)
    result = evt.getData()

    if result.wasSuccessful
        m.carousel.content = result.content
    end if

    loadContinueWatching()
end sub

sub onGetContinueWatching(evt)
    result = evt.getData()

    if result.wasSuccessful
        for each child in getAllChildren(result.content)
            child.update({ "template": "continue_watching" }, true)
        end for
        addRow(result.content, tr("continue_watching"), true, true)
    end if

    loadNewReleases()
end sub

sub onGetNewReleases(evt)
    result = evt.getData()
    if result.wasSuccessful
        addRow(result.content, tr("new_releases"))
    end if

    loadNewEpisodes()
end sub

sub onGetNewEpisodes(evt)
    result = evt.getData()
    if result.wasSuccessful
        for each child in getAllChildren(result.content)
            child.update({ "template": "new_episodes" }, true)
        end for
        addRow(result.content, tr("new_episodes"), true)
    end if

    loadPopularVideos()
end sub

sub onGetPopularVideos(evt)
    result = evt.getData()

    if result.wasSuccessful
        addRow(result.content, tr("popular_videos"))
    end if
end sub

sub showScreen()
    if m.cwRowReady = true and m.carouselReady = true and not m.screenInitialized
        m.screenInitialized = true
        isScreenLoading(false)
        startAnimation(m.screenAnimation)
        focusNode(m.scroller)


        m.global.liveStreamsManager.callFunc("getLiveShows")
    end if
end sub

sub addRow(content, title, hasTemplate = false, trackLoadStatus = false)
    'If empty don't add row
    if content.getChildCount() = 0
        if trackLoadStatus
            sendAppEvent({ name: m.showScreenEvent })
        end if

        return
    end if

    rowList = m.scrollerContainer.createChild("RowList")
    rowList.update(getRowListStyle(hasTemplate))

    rowListContent = createObject("roSGNode", "ContentNode")
    rowContent = rowListContent.createChild("ContentNode")
    rowContent.title = title

    rowContent.insertChildren(content.getChildren(-1, 0), 0)

    if trackLoadStatus
        trackedChild = getChildByIndexOrLastNode(rowContent, m.itemsPerRow - 1)
        if trackedChild <> invalid
            trackedChild.update({ trackLoadStatusEvent: m.showScreenEvent }, true)
        end if
    end if

    rowList.content = rowListContent
    rowList.observeField("itemSelected", "onGridItemSelected")
end sub

sub onGridItemSelected(evt)
    row = evt.getRoSGNode()
    content = row.content
    rowItemSelected = row.rowItemSelected

    if content <> invalid and rowItemSelected.count() > 1
        item = content.getChild(rowItemSelected[0]).getChild(rowItemSelected[1])
        if isValid(item)
            navigate("DetailScreen", item)
        end if
    end if
end sub

sub onCarouselReady(evt)
    if evt.getData()
        m.carouselReady = true
        showScreen()
    end if
end sub

sub onCarouselItemSelected(evt)
    itemSelcted = evt.getData()

    navigate("DetailScreen", itemSelcted)
end sub

sub onAppEvent(evt)
    event = evt.getData()

    if event?.name = m.showScreenEvent
        m.cwRowReady = true
        showScreen()
    end if
end sub

sub onLiveShowChanged(evt)
    liveStreamShow = evt.getData()

    if liveStreamShow <> invalid and isInteger(liveStreamShow.videoId) and liveStreamShow.videoId <> m.liveShowId
        m.liveShowId = liveStreamShow.videoId
        m.carousel.callFunc("addSlide", liveStreamShow)
    end if
end sub