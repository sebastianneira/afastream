function init()
    setComponents()
    setStyle()
    addObservers()
end function

sub setComponents()
    findNodes([
        "background"
        "container"
        "animation"
        "containerInterpolator"
        "leftArrow"
        "rightArrow"
        "dots"
        "animationTimer"
    ])
end sub

sub addObservers()
    m.container.observeField("focusedIndex", "onFocusedIndexChanged")
    m.animationTimer.observeField("fire", "onAnimationTimerFired")
end sub

sub setStyle()
    m.tileWidth = 1624
    m.tileHeight = 510
    m.containerTranslation = 99
    m.dotFocusOpacity = 0.6
    m.dotFocusOffOpacity = 0.3

    m.dotStyle = {
        width: 12
        height: 12
        opacity: m.dotFocusOffOpacity
        uri: "pkg:/images/carousel/dot.png"
    }

    m.background.update({
        height: m.tileHeight
        width: 1920
        color: "0x222121"
        clippingRect: [m.containerTranslation, 0, m.tileWidth, m.tileHeight]
    })

    m.dots.update({
        layoutDirection: "horiz"
        horizAlignment: "center"
        vertAlignment: "top"
        translation: [861, m.background.height + 15]
        itemSpacings: [15]
    })

    m.container.update({
        translation: [m.containerTranslation, 0]
        keyHoldAllowed: false
    })

    m.leftArrow.update({
        width: 60
        height: 60
        opacity: 0.4
        uri: "pkg:/images/carousel/arrow_left.png"
        translation: [129, 225]
    })

    m.rightArrow.update({
        width: 60
        height: 60
        opacity: 0.4
        uri: "pkg:/images/carousel/arrow_right.png"
        translation: [1633, 225]
    })

    m.animation.update({
        duration: "0.300",
        repeat: false,
        optional: true
    })

    m.containerInterpolator.update({
        key: [0.0, 1.0]
        fieldToInterp: "container.translation"
    })

    m.animationTimer.update({
        repeat: true
        duration: 8
    })
end sub

function addSlide(slide, position = 0)
    if isNode(slide)
        tile = CreateObject("roSGNode", "HeroTile")
        tile.observeField("selected", "onSlideSelected")
        tile.itemContent = slide

        m.container.insertChild(tile, position)
        m.container.callFunc("setFocused", { index: position, pasiveFocus: true })
        addDot()
    end if
end function

sub addDot()
    dot = m.dots.createChild("Poster")
    dot.update(m.dotStyle)
end sub

sub animateCarousel()
    x = (-m.container.focusedIndex * m.tileWidth) + m.containerTranslation
    m.containerInterpolator.keyValue = [m.container.translation, [x, 0]]
    startAnimation(m.animation)
end sub

sub focusContainerNextItem()
    nextIndex = m.container.focusedIndex + 1

    if nextIndex > m.container.getChildCount() - 1
        nextIndex = 0
    end if

    m.container.callFunc("setFocused", { index: nextIndex })
end sub

sub onContentChanged(evt)
    content = evt.getData()
    firstTile = true

    for each child in content.getChildren(-1, 0)
        tile = m.container.createChild("HeroTile")
        tile.observeField("selected", "onSlideSelected")
        tile.itemContent = child

        if firstTile = true
            tile.observeField("ready", "onFirstTileReady")
            'Wait 5 seconds as max for the tile image to load
            m.tmrLoading = CreateObject("roSGNode", "Timer")
            m.tmrLoading.duration = 5
            m.tmrLoading.observeField("fire", "onTmrLoadingFired")
            m.tmrLoading.control = "start"

            firstTile = false
        end if

        addDot()
    end for
end sub

sub onFocus()
    if m.top.isInFocusChain()
        focusNode(m.container)
        m.animationTimer.control = "start"
    else
        m.animationTimer.control = "stop"
    end if
end sub

sub onFocusedIndexChanged(evt)
    index = evt.getData()

    m.animationTimer.control = "stop"
    m.animationTimer.control = "start"

    for i = 0 to m.dots.getChildCount() - 1
        dot = m.dots.getChild(i)
        if i = index
            dot.opacity = m.dotFocusOpacity
        else
            dot.opacity = m.dotFocusOffOpacity
        end if
    end for

    animateCarousel()
end sub

sub onAnimationTimerFired(evt)
    if m.top.isInFocusChain() then focusContainerNextItem()
end sub

sub onTmrLoadingFired()
    if not m.top.ready then m.top.ready = true
end sub

sub onFirstTileReady(evt)
    m.top.ready = evt.getData()
end sub

function onSlideSelected(evt)
    item = evt.getRoSGNode()

    if item <> invalid
        m.top.selectedItem = item.itemContent
    end if
end function

function onKeyEvent(key as string, press as boolean) as boolean
    eventCaptured = false

    if not press return eventCaptured

    if key = "right"
        focusContainerNextItem()
        eventCaptured = true
    end if
end function
