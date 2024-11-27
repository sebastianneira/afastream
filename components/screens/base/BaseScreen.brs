
'*************************************************************************
'#region *** Screen setup
'*************************************************************************

sub init()
    baseSetComponents()
    baseInitComponent()
end sub

sub baseSetComponents()
    m.scene = m.top.getScene()
    m.config = m.global.getField("config")
    m.stackView = m.global.getField("stack")
    m.navigation = m.scene.findNode("navigation")
    m.httpTask = CreateObject("roSGNode", "HttpTask")
    m.screenAnimation = m.top.findNode("screnAnimation")
    m.screenOpacityInterpolator = m.top.findNode("screenOpacityInterpolator")
end sub

sub baseSetStyles()
    m.screenAnimation.update({
        duration: 1,
        optional: true
    })

    m.screenOpacityInterpolator.update({
        key: [0.0, 1.0],
        keyValue: [0.0, 1.0]
    })
end sub

sub baseAddObservers()
    m.top.observeField("isLoading", "onLoadingChanged")
    m.top.observeField("focusedChild", "onScreenFocusChanged")
    'm.inputManager.observeField("inputData", "onBaseInputTask")
    'm.global.observeField("isNetworkConnected", "onConnectionError")


    'Add only once on screen creation
    if m.scene <> invalid
        m.scene.observeField("appEvent", "baseOnAppEvent")
    end if
end sub

sub baseRemoveObservers()
    ' m.inputManager.unObserveField("inputData")
    ' m.global.unObserveField("isNetworkConnected")
end sub

sub baseInitComponent()
    m.settings = m.config.settings
    m.screenMode = m.settings.screenMode
    m.states = m.settings.screenStates
    m.isDebug = false
    m.screenClearMode = m.config.settings.screenCleanModes
    m.navigation.visible = false

    #if debug
        m.isDebug = true
    #end if
end sub

'*************************************************************************
'#region *** Screen Utils
'*************************************************************************

function isScreenEnabled() as boolean
    return m.top.state = m.states.init or m.top.state = m.states.revisit
end function

sub navigate(screen as string, model = invalid as dynamic, clearMode = "" as string)
    if isAssocArray(model)
        contentNode = createObject("roSGNode", "ContentNode")
        contentNode.update(model, true)
        model = contentNode
    end if

    params = {
        screen: screen,
        model: model,
        clearMode: clearMode
    }
    m.stackView.callFunc("navigate", params)
end sub

sub clearCurrentAndNavigate(screen as object, model = invalid as dynamic)
    navigate(screen, model, m.screenClearMode.current)
end sub

sub clearStackAndNavigate(screen as string, model = invalid as dynamic)
    navigate(screen, model, m.screenClearMode.stack)
end sub

sub showModal(modal as string, model = invalid as dynamic)
    params = { screen: modal, model: model, screenMode: m.screenMode.modal }
    m.stackView.callFunc("navigate", params)
end sub

sub showAlert(title = "" as string, message = "" as string, options = invalid as object)
    params = { screen: m.views.alert, model: { title: title, message: message, options: options },
    screenMode: m.screenMode.modal }
    m.stackView.callFunc("navigate", params)
end sub

sub closeModal(context = {} as object)
    navigateBack(context)
end sub

sub navigateBack(context = invalid as object)
    if isValid(context)
        m.stackView.callFunc("navigateBack", context)
    else
        m.stackView.callFunc("navigateBack")
    end if
end sub

sub fireREDTrackEvent(event = "")
    eventDispatcher = m.global.analyticsComponent

    if isValid(eventDispatcher)
        eventDispatcher.trackEvent = {RED: {eventName: event}}
    end if
end sub

sub fireAppLaunchComplete()
    if not m.global.appLaunchFired
        m.global.update({ "appLaunchFired": true })
        result = m.top.signalBeacon("AppLaunchComplete")
        if m.isDebug = true then ?"-- fireAppLaunchComplete: " result
    end if
end sub

sub fireAppDialogLaunch()
    if not m.global.appLaunchFired
        result = m.top.signalBeacon("AppDialogInitiate")
        if m.isDebug = true then  ?"-- fireAppDialogLaunch: " result
    end if
end sub

sub fireAppDialogComplete()
    if not m.global.appLaunchFired
        result = m.top.signalBeacon("AppDialogComplete")
        if m.isDebug = true then ?"-- fireAppDialogComplete: " result
    end if
end sub

'*************************************************************************
'#region *** base screen callbacks, DO NOT OVERRIDE this ones
'*************************************************************************

sub onLoadingChanged(evt)
    isLoading = evt.getData()

    if isLoading
        showLoader()
    else
        onScreenLoaded()
        hideLoader()
    end if
end sub

sub onStateChanged(obj)
    state = obj.getData()

    if state = m.states.init
        focusScreen = m.top.setFocusOnInitState

        m.top.setFields({
            visible: true
            focusable: true
            setFocus: focusScreen
        })

        m.navigation.callFunc("setSelectedByItemId", m.top.id)

        baseSetStyles()
        baseAddObservers()
        onScreenInit() 
    else if state = m.states.revisit or state = m.states.navBack
        focusScreen = m.top.setFocusOnActivateState

        m.top.setFields({
            visible: true
            focusable: true
            setFocus: focusScreen
        })

        if not focusScreen
            focusNode(m.navigation)
        end if

        if m.top.isLoading
            showLoader()
        else
            hideLoader()
        end if

        'Select menu option
        m.navigation.callFunc("setSelectedByItemId", m.top.id) 'Select menu option

        baseAddObservers()
        onScreenRevisit()
       
        if state = m.states.navBack
            onScreenNavBack(m.top.context)
        end if
    else if state = m.states.inactive
        m.top.setFields({
            visible: true
            focusable: false
        })

        baseRemoveObservers()
        onScreenInactive()
    else if state = m.states.sleep
        m.top.setFields({
            visible: false
            focusable: false
        })

        baseRemoveObservers()
        onScreenSleeping()
    else if state = m.states.closed
        baseRemoveObservers()
        onScreenClosed()
    end if
end sub

sub onSetFocusChanged(obj)
    setFocus = obj.getData()
    if setFocus then focusNode(m.top)
end sub

sub showLoader()
    if m.loader = invalid 
        m.loader = CreateObject("roSGNode", "Loader")
        m.loader.id = hideLoader

        m.top.appendChild(m.loader)
    end if
end sub

sub hideLoader()
    if m.loader <> invalid 
        m.top.removeChild(m.loader)
        m.loader = invalid
    end if
end sub

sub isScreenLoading(isLoading = true)
    m.top.isLoading = isLoading
end sub

function handleDeepLink(deeplink as object)
    print "deeplink not validated"
end function

function handleTransport(evt as object) as string
    'handled in VideoController
    if isScreenEnabled()
        return "unhandled"
    end if
end function

function sendAppEvent(event) as void
    if event <> invalid
        m.scene.appEvent = event
    end if
end function

sub onBaseInputTask(msg as Object)
    if isScreenEnabled() and type(msg) = "roSGNodeEvent" and msg.getField() = "inputData"
        inputData = msg.getData()
        if isValid(inputData)
            if inputData.type = "deeplink"
                handleDeepLink(inputData)
            else
                result = handleTransport(inputData)
                m.inputManager.transportResponse = { id: inputData.id, status: result }
            end if
        end if
    end if
end sub

sub onConnectionError(evt as dynamic)
    isConnected = evt.getData()

    if not isConnected
    end if
end sub

sub baseOnAppEvent(evt) as void
    onAppEvent(evt)
end sub
'*************************************************************************
'#region *** base event callbacks, override in your screen for usage
'*************************************************************************
sub onScreenInit()
end sub

sub onScreenLoaded()
end sub

sub onScreenRevisit()
end sub

sub onScreenNavBack(context = {})
end sub

sub onScreenInactive()
end sub

sub onScreenSleeping()
end sub

sub onScreenClosed()
end sub

sub onModelChanged()
end sub

sub onPressBack()
end sub

sub onScreenFocusChanged(evt)
end sub

sub onAppEvent(evt)
end sub

'*************************************************************************
'#region *** Key events
'*************************************************************************

sub onScreenKeyPress(key,press) as boolean
end sub

function onKeyEvent(key, press) as boolean
    eventCaptured = false

    if not press then return eventCaptured

    eventCaptured = onScreenKeyPress(key, press)
    
    if not eventCaptured and key = "back"
        onPressBack()
        if m.top.enablesNavigation
            focusNode(m.navigation)
            eventCaptured = true
        end if
    end if

    return eventCaptured
end function