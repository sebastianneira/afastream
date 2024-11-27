sub init()
    baseSetComponents()
    baseInitComponent()
    baseAddObservers()
end sub

sub baseSetComponents()
    m.container = m.top.findNode("container")
    m.containerAnimation = m.top.findNode("containerAnimation")
    m.translationInterpolator = m.top.findNode("translationInterpolator")
end sub

sub baseAddObservers()
    m.top.observeField("focusedChild", "onFocusChanged")
    m.container.observeField("focusedChild", "onContainerFocusChanged")
    m.container.observeField("keyHoldInProgress", "keyHoldProgressChanged")
    m.container.observeField("change", "onContainerChange")
    m.containerAnimation.observeField("state", "onAnimationStateChanged")
end sub

sub baseInitComponent()
    m.top.focusable = true
    m.top.clippingRect = [0, 0, 1920, 1080]
    m.selectedIndex = -1
    m.container.horizAlignment = "custom"
    m.container.vertAlignment = "custom"
    m.container.keyHoldDuration = 0.10
    m.checkViewAreaForAll = false
    m.isFirstFocus = true
    m.itemsPerPage = 0
end sub

sub onFocusChanged(evt as dynamic)
    if m.top.hasFocus()
        focusNode(m.container)
    end if
end sub

sub onAnimationStateChanged(evt)
    state = evt.getData()
    if state = "stopped"

    end if
end sub

sub onContainerFocusChanged(evt as dynamic)
    keyValue = invalid
    prevIndex = m.selectedIndex
    m.selectedIndex = m.container.focusedIndex

    prevItem = m.container.getChild(prevIndex)
    currentItem = m.container.getChild(m.selectedIndex)

    scroll = prevIndex <> m.selectedIndex and prevItem <> invalid

    if not scroll then return

    

    if not m.top.scollOnEveryItem and currentItem <> invalid
        boundingRect = currentItem.SceneBoundingRect()
        if m.selectedIndex > prevIndex
            scroll = boundingRect.y + currentItem.height > m.top.clippingRect.height
            
            ' if scroll and m.itemsPerPage = 0
            '     m.itemsPerPage = m.selectedIndex
            '     STOP
            ' end if
            
        else if currentItem.translation[1] + m.container.translation[1] > currentItem.clippingRect.height
            'avoid to put focused item on top when scrolling up
            scroll = false
        end if
    end if

    if scroll
        if keyValue = invalid
            keyValue = [m.container.translation, [m.container.translation[0], -currentItem.translation[1]]]
        end if

        m.translationInterpolator.keyValue = keyValue
        completeAnimation(m.containerAnimation) 'finish animation before start a new one
        startAnimation(m.containerAnimation)
    end if
end sub

sub onContainerChange(evt as dynamic)
    event = evt.getData()
    if event.operation = "add"

    end if
end sub

sub onRowScrolledEvent(evt)
    event = evt.getData()
    event.rowIndex = m.container.focusedIndex
    m.top.rowScrolledEvent = event
end sub

sub keyHoldProgressChanged(evt as dynamic)
    isHoldingKey = evt.getData()

    if isHoldingKey
        m.containerAnimation.duration = 0.05
    else
        m.containerAnimation.duration = 0.15
    end if
end sub

function resetContent(context = {} as object)
    m.container.removeChildrenIndex(m.container.getChildCount(), 0)
    m.container.translation = [0, 0]
    m.container.callFunc("setFocused", { index: 0 })
    m.selectedIndex = -1
end function

function scrollTop(context = {} as object)
    completeAnimation(m.containerAnimation)
    pasiveFocus = iif(context.pasiveFocus <> invalid, context.pasiveFocus, false)
    m.container.callFunc("setFocused", {index: 0, pasiveFocus: pasiveFocus})
end function

function onKeyEvent(key, press) as boolean
    eventCaptured = false

    if not press return eventCaptured

    if press
        if key = "back"
            if m.container.focusedIndex > 0
                scrollTop()
                eventCaptured = true
            end if
        end if
    end if

    return eventCaptured
end function
