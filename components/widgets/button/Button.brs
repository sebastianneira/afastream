sub init()
    setComponents()
    addObservers()
    setStyles()
    initComponent()
end sub

sub setComponents()
    findNodes([
        "background"
        "content"
        "icon"
        "title"
        "animation"
        "bgColorInterpolator"
    ])
end sub

sub addObservers()
    m.top.observeField("enabled", "onEnabledChanged")
    m.top.observeField("focusedChild", "onFocusChanged")
    m.top.observeField("static", "onStaticChanged")
    m.top.observeField("progressPercent", "onProgressChanged")
    m.top.observeField("maxWidth", "onMaxWidthChanged")
    m.top.observeField("height", "onHeightChanged")
    m.top.observeField("color", "onColorChanged")
    m.top.observeField("focusColor", "onColorChanged")
    m.icon.observeField("loadStatus", "onIconLoaded")
    m.title.observeField("text", "onTextChanged")
end sub

sub setStyles()
    m.top.maxWidth = 180
    m.padding = 30

    m.background.update({
        color: m.top.color
        width: m.top.maxWidth + m.padding * 2
        height: m.top.height
    })

    ' m.content.update({
    '     layoutDirection: "horiz"
    '     vertAlignment: "center"
    '     itemSpacings: [12]
    '     translation: [33, m.padding]
    ' })

    m.progressBarBgStyle = {
        color: "0x000000"
        width: 0
        height: 6
        translation: [0,60]
        opacity: 0.75
    }

    m.progressBarStyle = {
        color: "0xEA3323"
        width: 0
        height: 6
    }

    m.icon.update({
        width: 33
        height: 33
        translation: [m.padding, 15]
    })

    m.title.update({
        horizAlign: "center"
        vertAlign: "center"
        maxWidth: m.top.maxWidth
        height: m.top.height
        repeatCount: 0
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 24
        }
        color: "0xFFFFFF"
        translation: [m.padding, 0]
    })

    m.animation.update({
        repeat: false
        optional: true
    })

    m.bgColorInterpolator.update({
        key: [0.0, 1.0],
        keyValue: [m.top.color, m.top.focusColor],
        fieldToInterp: "background.color"
    })
end sub

sub initComponent()
    m.titleWidth = 0
end sub

sub setStateStyle(state as object)
    if state = invalid then return

    for each element in state.Keys()
        if m[element] <> invalid
            m[element].update(state[element])
        end if
    end for
end sub

sub adjustMaxWidth(stopIt = false)
    if len(m.title.text) = 0 then return 'avoid empty text scenario

    if m.top.flexible
        titleWidth = m.title?.getChild(0).boundingRect().width
        isTitleSizeBelowMax = titleWidth < m.top.maxWidth
        isBackgroundSizeSmall = (titleWidth > m.background.width - m.title.translation[0] * 2) and isTitleSizeBelowMax 'then btn text is changed after first time
        hasIcon = m.icon.uri <> "" 

        if isTitleSizeBelowMax or isBackgroundSizeSmall
            m.title.maxWidth = titleWidth
            'if stopIt then stop
            if hasIcon
                m.background.width = m.title.translation[0] + titleWidth + (m.padding * 1.6)
            else
                m.background.width = titleWidth + m.padding * 2
            end if
        else if hasIcon
            m.background.width = m.title.translation[0] + m.title.maxWidth + (m.padding * 1.6)
        end if
    else
        m.background.width = m.top.maxWidth + m.padding * 2
        m.title.maxWidth = m.top.maxWidth
    end if
end sub

sub onFocusChanged()
    hasFocus = m.top.hasFocus()

    if not m.top.selected
        if m.top.animate
            startAnimation(m.animation, not m.top.isInFocusChain())
        else if m.top.keepSelection
            m.background.color = iif(hasFocus, m.top.focusColor, m.top.color)
        end if
    end if

    if hasFocus
        m.title.repeatCount = -1
    else
        m.title.repeatCount = 0
    end if
end sub

sub onTextChanged(evt as dynamic)
    adjustMaxWidth()
end sub

sub onIconLoaded(evt as dynamic)
    if evt.getData() = "ready"
        titleTranslationX = (m.padding/2) + m.icon.translation[0] + m.icon.width
        m.title.translation = [titleTranslationX, 0]

        adjustMaxWidth(true)
    end if
end sub

sub onEnabledChanged(evt as dynamic)
    isEnabled = evt.getData()

    if isEnabled
        m.top.opacity = 1
    else
        m.top.opacity = 0.5
    end if
end sub

sub onStaticChanged(evt as dynamic)
    m.background.visible = not evt.getData()
end sub

sub onProgressChanged(evt as dynamic)
    percentage = evt.getData()
    
    if percentage <> invalid and percentage > 0
        if m.progressBarBg = invalid then
            m.progressBarBg = m.background.createChild("Rectangle")
            m.progressBar = m.progressBarBg.createChild("Rectangle")

            m.progressBarBg.update(m.progressBarBgStyle)
            m.progressBar.update(m.progressBarStyle)
        end if

        m.progressBarBg.width = m.background.width
        m.progressBarBg.translation = [0, m.top.height - m.progressBar.height]
        m.progressBar.width = getProgressBarWidth(percentage, m.background.width)
    end if
end sub

sub onMaxWidthChanged(evt as dynamic)
    adjustMaxWidth()
end sub

sub onHeightChanged(evt as dynamic)
    height = evt.getData()

    m.background.height = height
    m.title.height = height
end sub

sub onColorChanged(evt as dynamic)
    m.background.color = m.top.color
    m.bgColorInterpolator.update({
        key: [0.0, 1.0],
        keyValue: [m.top.color, m.top.focusColor],
        fieldToInterp: "background.color"
    })
end sub
