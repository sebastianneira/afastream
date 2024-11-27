sub init()
    setComponents()
    addObservers()
    initComponent()
end sub

sub setComponents()
    findNodes([
        "container",
        "animation",
        "translationInterpolator"
    ])
end sub

sub addObservers()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.container.observeField("focusedChild", "onFocusedElementChanged")
end sub

sub initComponent()
    m.screenResolution = { width: 1920, height: 1080 } 'TOOD: take from config
    m.top.focusable = true
    m.selectedIndex = -1
    m.top.container = m.container
end sub

sub onContentChanged(content as Object)
    model = content.getData()

    if isValid(model)
        m.container.removeChildrenIndex(m.container.getChildCount(), 0)

        for each contentItem in model.content
            item = m.container.createChild(model.component)
            item.update(contentItem)
            
            if isValid(model.style) and item.hasField("style") then item.style = model.style
        end for
    end if
end sub

sub scrollTo(xTranslation = 0, yTranslation = 0)
    m.translationInterpolator.keyValue = [m.container.translation, [xTranslation, yTranslation]]
    m.animation.control = "start"
end sub

sub onFocusedElementChanged(evt as Dynamic)
    selectedItem = evt.getData()

    if isValid(selectedItem) and m.top.isInFocusChain()
        previousIndex = m.selectedIndex
        m.selectedIndex = m.container.focusedIndex
        prevItem = m.container.getChild(previousIndex)

        scrollHorizontally(selectedItem, prevItem, m.selectedIndex, previousIndex)
    end if
end sub

sub scrollHorizontally(selectedItem, prevItem, selectedIndex, previousIndex)
    itemRect = selectedItem.SceneBoundingRect()
    
    if selectedIndex > previousIndex
        offScreenX = (itemRect.x + itemRect.width + m.container.itemSpacings[0]) - m.screenResolution.width
        if offScreenX > 0
            scrollTo(m.container.translation[0] -offScreenX, m.container.translation[1])
        end if
    else if itemRect.x < m.top.translation[0]
        scrollTo(-selectedItem.translation[0], m.container.translation[1])
    end if
end sub

sub onFocusChanged()
    if m.top.hasFocus() then focusNode(m.container)
end sub

function onKeyEvent(key, press) as boolean
    eventCaptured = false

    if press return eventCaptured

    if key = "OK"
        m.top.selected = m.container.getChild(m.container.focusedIndex)
        eventCaptured = true
    end if

    return eventCaptured
end function
