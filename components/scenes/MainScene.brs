sub init()
    setComponents()
    initComponent()
    addObservers()
    setStyles()
end sub

sub setComponents()
    findNodes([
        "background"
        "navigation"
        "content"
        "stack"
        "store"
        "animation"
        "tabBarOpacityInterpolator"
        "loader"
        "exitMessage"
        "exitLabel"
        "confirmBtns"
        "btnConfirm"
        "btnCancel"
    ])
end sub

sub addObservers()
    m.navigation.observeField("selected", "onNavOptionChanged")
end sub

sub setStyles()
    m.exitLabel.update({

    })

    m.confirmBtns.update({

    })

    m.btnConfirm.update({

    })

    m.btnCancel.update({

    })

    m.background.update({
        width: 1920
        height: 1080
        color: "0x222121"
    })

    m.animation.update({
        repeat: false
        duration: 0.20
        optional: true
    })
end sub

sub onTimerSessionFired()
end sub

function initializeRAC()
    RAC = createObject("roSGNode", "Roku_Analytics:AnalyticsNode")
    if isValid(RAC)
        RAC.debug = m.isDebug
        RAC.init = { RED: {} }
    end if

    return RAC
end function

sub initComponent()
    m.config = m.global.getField("config")
    m.contentYScroll = 0
    m.environmentApiUrl = invalid
    m.isDebug = false

    #if debug
        m.isDebug = true
    #end if

    resolutionName = getDeviceUIResolution().name
    devicePixelRatio = 1
    if resolutionName = "HD" then
        devicePixelRatio = 2 / 3
    end if

    m.global.update({
        "stack": m.stack,
        "environmentUrl": m.config.settings.environment.environmentUrl
        "environmentAPIUrl": m.config.settings.environment.environmentAPIUrl
        "user": CreateObject("roSGNode", "UserModel")
        "userStateManager": CreateObject("roSGNode", "UserStateManager")
        "liveStreamsManager": CreateObject("roSGNode", "LiveStreamsManager")
        "registryTask": CreateObject("roSGNode", "registryTask")
        "appLaunchFired": false
    }, true)

    initChannel()
end sub

sub initChannel()
    initNavBar()
    m.stack.callFunc("navigate", { screen: "StartupScreen" })
end sub

sub initNavBar()
    menuOptions = CreateObject("roSGNode", "ContentNode")
    menuOptions.update({ items: m.global.config.menu }, true)
    m.navigation.content = menuOptions
end sub

sub onNavOptionChanged(evt as dynamic)
    option = evt.getData()

    if isValid(option)
        m.stack.callFunc("navigate", { screen: option })
    end if
end sub


sub onNavigationEnabled(evt as object)
    isNavEnabled = evt.getData()
    m.navigation.enabled = isNavEnabled
end sub

function onKeyEvent(key, press) as boolean
    eventCaptured = false

    if not press then return eventCaptured

    if key = "left" and m.stack.isInFocusChain() and m.navigation.visible
        focusNode(m.navigation)
        eventCaptured = true
    else if key = "right" and m.navigation.isInFocusChain()
        focusNode(m.stack)
        eventCaptured = true
    else if key = "back"
        if m.stack.isInFocusChain() and m.navigation.visible
            focusNode(m.navigation)
            eventCaptured = true
        else if m.navigation.isInFocusChain()
            eventCaptured = true
        else
            eventCaptured = m.stack.callFunc("navigateBack")
        end if
    end if

    return eventCaptured
end function
