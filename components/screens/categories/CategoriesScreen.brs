'*************************************************************************
'#region *** Screen setup
'*************************************************************************

function init() as void
    setComponents()
    setStyles()
    initComponent()
end function

sub setComponents()
    findNodes(["container", "category", "categoryGrid", "categoryTitle", "categoryDescription", "categoriesList", "filterBar"])
end sub

sub setStyles()
    rowListStyle = copyAssocArray(m.config.styles.defaultRowList)
    rowListStyle.numRows = 2
    rowListStyle.translation = [198, 150]
    rowListStyle.itemSpacing = [0,99]
    rowListStyle.vertFocusAnimationStyle = "floatingFocus"
    m.categoriesList.update(rowListStyle)

    m.categoryGrid.update({
        itemSize: [210,300]
        itemSpacing: [21,30]
        numRows: 2
        numColumns: 6
        itemComponentName: "HomeTile" 
        drawFocusFeedback: "true"
        translation: [192, 330]
        vertFocusAnimationStyle: "floatingFocus"
    })

    m.filterBar.update({
        translation:[198, 60]
        itemSpacings: [21]
    })

    m.category.visible = true

    m.categoryTitle.update({
        color: "0xFFFFFF"
        maxLines: 1
        font: {
            subType: "font",
            role: "font",
            uri: "pkg:/locale/font/Roboto-Regular.ttf",
            size: 36
        }
        translation: [198, 150]
    })

    m.categoryDescription.update({
        color: "0xFFFFFF"
        maxLines: 2
        width: 1500
        wrap: true
        font: {
            subType: "font",
            role: "font",
            uri: "pkg:/locale/font/Roboto-Regular.ttf",
            size: 21
        }
        translation: [198, 225]
    })

    m.container.opacity = 0

    m.screenOpacityInterpolator.fieldToInterp = "container.opacity"
end sub

sub initComponent()
    m.showScreenEvent = "categoriesReadyAppEvent"
    m.showCategoryEvent = "categoryReadyEvent"
    m.selectedCategoryItem = invalid
    m.screenShown = false
end sub

'*************************************************************************
'#region *** Screen events
'*************************************************************************
sub onScreenInit()
    loadAllCategories()
end sub

sub onScreenRevisit()
    focusNode(getCurrentGrid())
end sub

sub onAppEvent(evt)
    event = evt.getData()

    if event?.name = m.showScreenEvent and m.screenShown = false
        showScreen()
        m.screenShown = true
    end if
end sub

sub showScreen()
    focusNode(m.categoriesList)
    isScreenLoading(false)
    startAnimation(m.screenAnimation)
end sub

'*************************************************************************
'#region *** Screen logic
'*************************************************************************
sub showAllCategories(showAll = true)
    m.categoriesList.visible = showAll
    m.category.visible = not showAll

    if showAll
        focusNode(m.categoriesList)
    end if
end sub

sub loadAllCategories()
    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        path: "video/categories"
        method: "POST"
        body: {
            "includeAll": true
        }
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.request = requestContext.callFunc("getRequest")
    requestNode.observeFieldScoped("response", "onGetCategories")
    m.httpTask.requests = [requestNode]

    isScreenLoading(true)
end sub

sub loadCategory(categoryId)
    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        path: "video/category"
        method: "POST"
        body: {
            "categoryId": categoryId,
            "take": 99,
            "page": 1,
            "includeAll": false
        }
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.request = requestContext.callFunc("getRequest")
    requestNode.observeFieldScoped("response", "onGetIndividualCategory")
    m.httpTask.requests = [requestNode]

    isScreenLoading(true)
end sub

'*************************************************************************
'#region *** Screen utils
'*************************************************************************
function getCurrentGrid()
    if m.categoriesList.visible 
        return m.categoriesList
    else
        return m.categoryGrid
    end if
end function

'*************************************************************************
'#region *** Screen callbacks
'*************************************************************************
sub onGetCategories(evt)
    result = evt.getData()

    if not result.wasSuccessful 
        navigateBack()
        return
    end if
    
    content = result.content
    rowListContent = createObject("roSGNode", "ContentNode")
    trackRow = true

    allItem = m.filterBar.container.createChild("FilterItem")
    allItem.update({ id: "all", text: tr("all")})
    allItem.selected = true
    allItem.observeField("selected", "onCategorySelected")
    
    for each child in content.getChildren(-1,0)
        rowContent = rowListContent.createChild("ContentNode")
        rowContent.title = child.heading

        for i=0 to iif(child.videos.count() < 5, child.videos.count() - 1, 4)
            video = child.videos[i]
            tile = rowContent.createChild("ContentNode")
            tile.update(video, true)
        end for

        if trackRow
            trackedChild = getChildByIndexOrLastNode(rowContent, 4)
            if trackedChild <> invalid then trackedChild.update({ trackLoadStatusEvent: m.showScreenEvent}, true)

            trackRow = false
        end if

        seeAllItem = rowContent.createChild("ContentNode")
        seeAllItem.update({
            id: child.id.toStr()
            showAllItems: true
        }, true)

        'Add item to filter bar
        item = m.filterBar.container.createChild("FilterItem")
        item.text = child.heading
        item.id = child.id.toStr()
        item.observeField("selected", "onCategorySelected")
    end for
    
    m.selectedCategoryItem = allitem
    m.categoriesList.content = rowListContent
    m.categoriesList.observeField("itemSelected", "onListItemSelected")
end sub

sub onGetIndividualCategory(evt)
    result = evt.getData()
    
    if not result.wasSuccessful 
        showAllCategories()
        isScreenLoading(false)
        return
    end if
    
    content = result.content
    markupListContent = createObject("roSGNode", "ContentNode")

    m.categoryTitle.text = content["title"]
    m.categoryDescription.text = content["content"]

    if hasElements(content.videos)
        for each video in content.videos
            tile = markupListContent.createChild("ContentNode")
            tile.update(video, true)
        end for

        trackedChild = getChildByIndexOrLastNode(markupListContent, 5)
        if trackedChild <> invalid then trackedChild.update({ trackLoadStatusEvent: m.showCategoryEvent}, true)

        m.categoryGrid.content = markupListContent
        m.categoryGrid.observeField("itemSelected", "onGridItemSelected")
        
        showAllCategories(false)
        isScreenLoading(false)
    end if
end sub

sub onListItemSelected(evt)
    row = evt.getRoSGNode()
    content = row.content
    rowItemSelected = row.rowItemSelected

    if content <> invalid and rowItemSelected.count() > 1
        item = content?.getChild(rowItemSelected[0])?.getChild(rowItemSelected[1])

        if item.showAllItems = true
            item = m.filterBar.container.findNode(item.id)
            item.selected = true

            focusNode(m.categoryGrid)
        else if isValid(item) 
            navigate("DetailScreen", item)
        end if
    end if
end sub

sub onGridItemSelected(evt)
    index = evt.getData()
    item = m.categoryGrid.content.getChild(index)
    
    if isValid(item) 
        navigate("DetailScreen", item)
    end if
end sub

sub onCategorySelected(evt)
    wasSelected = evt.getData()
    item = evt.getRoSGNode()

    if not wasSelected then return

    if m.selectedCategoryItem <> invalid 
        m.selectedCategoryItem.selected = false
    end if

    m.selectedCategoryItem = item
    
    if item.id = "all"
        showAllCategories()
    else
        loadCategory(item.id)
    end if
end sub

'*************************************************************************
'#region *** Key events
'*************************************************************************

function onScreenKeyPress(key, press)
    eventCaptured = false 

    grid = getCurrentGrid()

    if key = "up" or key = "back" and grid.isInFocusChain()
        if key = "back" and grid.itemFocused > 0
            grid.animateToItem = 0
        else
            focusNode(m.filterBar)
        end if

        eventCaptured = true
    else if key = "back" and m.filterBar.isInFocusChain() and m.selectedCategoryItem.id <> "all"
        item = m.filterBar.container.findNode("all")
        item.selected = true

        focusNode(m.categoriesList)
        eventCaptured = true
    else if key = "down" and m.filterBar.isInFocusChain()
        focusNode(grid)
        eventCaptured = true
    end if

    return eventCaptured
end function