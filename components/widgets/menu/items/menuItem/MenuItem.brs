sub init()
    setComponents()
    addObservers()
    initComponent()
    initStyle()
end sub

sub setComponents()
    findNodes([
        "itemGroup"
        "icon"
        "selectedIcon"
        "label"
        "grpLabel"
        "grpIcon"
        "options"
        "animation"
        "translationInterpolator"
        "opacityInterpolator"
    ])
end sub

sub addObservers()
    m.top.observeField("subOptions", "onSubOptionsChanged")
    m.top.observeField("setSelected", "onSetSelectedChanged")
end sub

sub initComponent()
end sub

sub removeObservers()
    m.top.unobserveField("focusedChild")
end sub

sub initStyle()
    m.animationConstant = 0.05
    m.focusColor = "0xFFFFFF"
    m.unFocusedColor = "0xCCCCCC"
    m.focusOpacity = 1
    m.unFocusedOpacity = .7

    m.itemGroup.update({
        layoutDirection: "horiz"
        itemSpacings: [30]
    })

    m.icon.update({
        width: 36
        height: 36
        blendColor: "0xFFFFFF"
        translation: [15, 3]
        opacity: m.unFocusedOpacity
    })

    m.selectedIcon.update({
        width: 69
        height: 39
        color: "0xFFFFFF"
        uri: "pkg:/images/33px-round-fhd.9.png"
        visible: false
    })

    m.grpLabel.update({
        translation: [90, 0]
        opacity: 0
    })

    m.label.update({
        color: m.unFocusedColor
        opacity: m.unFocusedOpacity
    })

    m.animation.update({
        duration: "0.30",
        repeat: false,
        easeFunction: "easeOut",
        optional: true
    })

    m.translationInterpolator.update({
        key: [0.0, 1.0],
        keyValue: [[0, 0], m.grpLabel.translation],
        fieldToInterp: "grpLabel.translation"
    })

    m.opacityInterpolator.update({
        key: [0.0, 1.0],
        keyValue: [m.grpLabel.opacity, m.unFocusedOpacity],
        fieldToInterp: "grpLabel.opacity"
    })
end sub

sub onFocus(evt)
    hasFocus = m.top.hasFocus()
    m.label.opacity = iif(hasFocus, m.focusOpacity, m.unFocusedOpacity)
    m.label.color = iif(hasFocus, m.focusColor, m.unFocusedColor)
    m.icon.opacity = iif(hasFocus or m.top.isSelected, m.focusOpacity, m.unFocusedOpacity)

    focusNode(m.label)
end sub

function setSelectedState(isSelected)
    m.selectedIcon.visible = isSelected
    m.icon.update({
        blendColor: iif(isSelected, "0x000000", "0xFFFFFF")
        opacity: iif(isSelected, m.focusOpacity, m.unFocusedOpacity)
    })

end function

function animateItem(params)
    index = getValue(params, "index", 1)
    animationType = getValue(params, "animation", "swipe")

    if animationType = "swipe"
        swipeItem(index)
    else
        fadeItem(index)
    end if
end function

function fadeItem(index)
    m.animation.removeChild(m.translationInterpolator)
    m.grpLabel.update(m.style.grpLabel) 'reset group styling
    m.animation.duration = (m.animationConstant * index).toStr()

    startAnimation(m.animation)
end function

function swipeItem(index)
    m.animation.duration = (m.animationConstant * index).toStr()
    startAnimation(m.animation)
end function

function hideItemText()
    if m.animation.state = "running" then m.animation.control = "finish"
    m.grpLabel.opacity = 0
end function

function showItemText()
    if m.animation.state = "running" then m.animation.control = "finish"
    m.grpLabel.opacity = 1
end function

function onKeyEvent(key as string, press as boolean) as boolean
    handled = false

    if press and key = "OK"
        m.top.isSelected = true
        setSelectedState(true)
        handled = true
    end if

    return handled
end function