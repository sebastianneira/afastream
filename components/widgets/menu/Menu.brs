function init()
    setComponents()
    initComponent()
end function

sub setComponents()
    findNodes([
        "background"
        "container"
        "playLogo"
        "afaLogo"
        "options"
        "animation"
        "containerTranslationIntr"
        "logoPlayTranslationIntr"
        "playLogoOpacityIntr"
        "afaLogoOpacityIntr"
        "bgOpacityIntr"
    ])
end sub

sub setStyles()
    m.bgEndWidth = 360
    
    m.background.update({
        width: 99
        height: 1080
        color: "0x000000"
    })

    m.container.update({
        translation: [15, 45]
    })

    m.playLogo.update({
        width: 81
        height: 78
        uri: "pkg:/images/menu/logo-play-2.png"
        opacity: 1
        translation: [9,66]
    })

    m.afaLogo.update({
        width: 300
        height: 57
        uri: "pkg:/images/menu/logo-expanded.png"
        opacity: 0
        translation: [36,75]
    })

    m.options.update({
        translation: [0, 132]
        itemsPacings: [36]
    })

    m.animation.update({
        duration: "0.200",
        repeat: false,
        optional: true
    })

    m.containerTranslationIntr.update({
        key: [0.0, 1.0],
        keyValue: [m.container.translation, [75, m.container.translation[1]]],
        fieldToInterp: "container.translation" 
    })

    m.logoPlayTranslationIntr.update({
        key: [0.0, 1.0],
        keyValue: [m.playLogo.translation, [m.bgEndWidth/3, m.playLogo.translation[1]]],
        fieldToInterp: "playLogo.translation" 
    })

    m.playLogoOpacityIntr.update({
        key: [0.0, 0.5, 1.0],
        keyValue: [1.0, 0.3, 0.0],
        fieldToInterp: "playLogo.opacity"
    })

    m.afaLogoOpacityIntr.update({
        key: [0.0, 0.5, 1.0],
        keyValue: [0.0, 0.0, 1.0],
        fieldToInterp: "afaLogo.opacity"
    })

    m.bgOpacityIntr.update({
        key: [0.0, 1.0],
        keyValue: [m.background.width, m.bgEndWidth],
        fieldToInterp: "background.width"
    })
end sub

sub initComponent()
    m.isMenuOpen = false
    m.selectedMenuChild = invalid
    m.selectedMenuParent = invalid
    m.previousSelectedMenuChild = invalid 'menu saves its own state so we know what to highlight'
    
    setStyles()
end sub

sub onFocus()
    if m.top.isInFocusChain()
        focusNode(m.options)
        if not m.isMenuOpen
            m.isMenuOpen = true
            startAnimation(m.animation)
            animateItems(m.options, "swipe")
        end if
    else
        m.isMenuOpen = false
        hideItems(m.options)
        startAnimation(m.animation, true)
    end if
end sub

sub onContentChanged(evt)
    content = evt.getData()

    for each option in content.items
        child = m.options.createChild("MenuItem")
        child.update(option)
        child.observeField("isSelected", "onItemSelected")
    end for
end sub

sub animateItems(container, animation = "swipe")
    index = 1
    for each option in container.getChildren(-1, 0)
        option.callFunc("animateItem", { index: index, animation: animation })
        index++
    end for
end sub

sub hideItems(container)
    for each option in container.getChildren(-1, 0)
        option.callFunc("hideItemText")
    end for
end sub

sub showItems(container)
    for each option in container.getChildren(-1, 0)
        option.callFunc("showItemText")
    end for
end sub

function onItemSelected(evt)
    item = evt.getRoSGNode()
    
    if iif(m.top.allowOptionRefresh, true, item?.screen?.id <> m.selectedMenuChild?.screen?.id)
        if isValid(m.selectedMenuChild)
            m.previousSelectedMenuChild = m.selectedMenuChild
            m.selectedMenuChild.callFunc("setSelectedState", false)
        end if

        m.selectedMenuChild = item
        m.top.selected = item.screen.view
    end if
end function

' /**
' * @description Forces the selection of a item in the navigation menu
' * @param {Object} item node
' */
function setSelected(item, index)
    if isValid(item) and item?.screen?.id <> m.selectedMenuChild?.screen?.id
        item.callFunc("setSelectedState", true)
        if isValid(m.selectedMenuChild)
            m.selectedMenuChild.callFunc("setSelectedState", false)
        end if
        
        m.options.callFunc("setFocused", {index: index, pasiveFocus: true})

        m.previousSelectedMenuChild = m.selectedMenuChild
        m.selectedMenuChild = item
    end if
end function

' /**
' * @description Forces the selection of a item in the navigation menu by the item id
' * @param {Object} item id
' */
function setSelectedByItemId(itemId)
    for i=0 to m.options.getChildCount() - 1
        item = m.options.getChild(i)
        if item.screen.view = itemId
            setSelected(item, i)
            exit for
        end if 
    end for
end function