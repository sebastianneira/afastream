function init() as void
    setComponents()
    addObservers()
    setStyles()
    initComponent()
end function

function setComponents()
    findNodes([
        "searchBox"
        "noResultsLbl"
        "searchResults"
        "keyboard"
    ])
end function

function addObservers()
    m.searchBox.observeField("text", "onValueChanged")
    m.searchBox.observeField("selected", "onSearchBoxSelected")
    m.keyboard.observeField("text", "onKeyboardTextChanged")
    m.searchResults.observeField("itemSelected", "onGridItemSelected")
end function

function initComponent()
    m.showScreenEvent = "searchReadyAppEvent"
    m.screenInitialized = false
    m.isSearching = false
    m.popularVideosContent = invalid
    hideKeyboard()
end function

sub onScreenInit()
    isScreenLoading()
    loadPopularVideos()
end sub 

sub onScreenRevisit() as void
    focusNode(m.searchResults)
end sub

function setStyles()
    rowListStyle = copyAssocArray(m.config.styles.defaultRowList)
    m.searchBox.update({
        translation: [630,90]
        width: 660
        height: 69
        hint: tr("search")
    })

    rowListStyle.numRows = 1
    rowListStyle.opacity = 0
    rowListStyle.translation = [198, 225]
    m.searchResults.update(rowListStyle)

    m.noResultsLbl.update({
        text: ""
        width: 1920
        maxLines: 1
        horizAlign: "center"
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 45
        }
        color: "0xCCCCCC"
        translation: [0,300]
    })

    m.screenOpacityInterpolator.fieldToInterp = "searchResults.opacity"
end function

function loadPopularVideos()
    if m.popularVideosContent = invalid
        requestContext = CreateObject("roSGNode", "RequestContext")
        requestContext.update({
            path: "video/popularvideos"
            method: "POST"
            body: {
                "take": 10,
                "page": 0
            }
        })

        requestNode = createObject("roSGNode", "RequestNode")
        requestNode.request = requestContext.callFunc("getRequest")
        requestNode.observeFieldScoped("response", "onGetPopularVideos")
        m.httpTask.requests = [requestNode]
    else
        m.searchResults.content = m.popularVideosContent
    end if
end function

function search(query)
    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        path: "video/search"
        method: "POST"
        parser: "search"
        body: {
            "query": query,
            "take": 20,
            "page": 0
        }
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.request = requestContext.callFunc("getRequest")
    requestNode.observeFieldScoped("response", "onSearchResult")
    m.httpTask.requests = [requestNode]
end function

sub showKeyboard()
    m.keyboard.update({
        context: { text: m.searchBox.text }
        visible: true
    })
    focusNode(m.keyboard)
end sub

sub hideKeyboard()
    m.keyboard.visible = false
    focusNode(m.searchBox)
end sub

sub setSearchState(isSearching = true)
    m.isSearching = isSearching
    isScreenLoading(isSearching)
end sub

sub toggleNoResultsLbl(showLabel = true)
    m.noResultsLbl.visible = showLabel
    m.searchResults.visible = not showLabel
end sub

sub showScreen()
    isScreenLoading(false)
    startAnimation(m.screenAnimation)
end sub

'*************************************************************************
'#region *** Event callbacks
'*************************************************************************

sub onSearchResult(evt)
    result = evt.getData()
    
    if result.wasSuccessful and result.content.getChildCount() > 0
        content = result.content
        rowListContent = createObject("roSGNode", "ContentNode")
        rowContent =  rowListContent.createChild("ContentNode")
        rowContent.title = Substitute(tr("search_results"), result.content.getChildCount().toStr(), m.keyboard.text)

        rowContent.insertChildren(content.getChildren(-1,0), 0)
        m.searchResults.content = rowListContent

        toggleNoResultsLbl(false)
    else
        m.noResultsLbl.text = Substitute(tr("no_search_results"), m.keyboard.text)
        toggleNoResultsLbl(true)
    end if

    setSearchState(false)
end sub

sub onGetPopularVideos(evt)
    result = evt.getData()
    content = result.content

    m.popularVideosContent = createObject("roSGNode", "ContentNode")
    rowContent = m.popularVideosContent.createChild("ContentNode")
    rowContent.title = tr("popular_videos")

    rowContent.insertChildren(content.getChildren(-1,0), 0)

    trackedChild = getChildByIndexOrLastNode(rowContent, 5)
    if trackedChild <> invalid
        trackedChild.update({ trackLoadStatusEvent: m.showScreenEvent}, true)
    end if

    m.searchResults.content = m.popularVideosContent

    focusNode(m.searchResults)
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

sub onSearchBoxSelected()
    showKeyboard()
end sub

sub onKeyboardTextChanged(evt)
    query = evt.getData()
    m.searchBox.text = query

    if Len(query) > 1 and not m.isSearching
        search(query)
        setSearchState(true)
    else if Len(query) = 0
        if m.popularVideosContent = invalid
            loadPopularVideos()
        else
            m.searchResults.update({
                visible: true
                content: m.popularVideosContent
            })
        end if
    end if
end sub

sub onAppEvent(evt)
    event = evt.getData()
    if event?.name = m.showScreenEvent and not m.screenInitialized
        showScreen()
        m.screenInitialized = true
    end if
end sub

function onKeyEvent(key, press) as boolean
    eventCaptured = false

    if not press return eventCaptured

    if key = "up"
        if m.searchResults.isInFocusChain()
            focusNode(m.searchBox)
            eventCaptured = true
        else if m.keyboard.isInFocusChain() and m.searchResults.visible
            hideKeyboard()
            focusNode(m.searchResults)
            eventCaptured = true
        end if
    else if key = "down"
        if m.searchBox.isInFocusChain()
            focusNode(m.searchResults)
            eventCaptured = true
        else if m.searchResults.isInFocusChain() and m.keyboard.visible
            focusNode(m.keyboard)
            eventCaptured = true
        else if m.keyboard.isInFocusChain()
            focusNode(m.searchBox)
            eventCaptured = true
        end if
    else if key = "back"
        if m.keyboard.isInFocusChain()
            hideKeyboard()
            focusNode(m.searchBox)
            eventCaptured = true
        end if
    end if

    return eventCaptured
end function
