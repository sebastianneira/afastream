sub init()
    setComponents()
    addObservers()
    initComponent()
end sub

sub setComponents()
    m.screenStack = m.top.findNode("screens")
end sub

sub addObservers()
    m.top.observeField("focusedChild", "onFocusChanged")
end sub

sub initComponent()
    m.config = m.global.getField("config")
    m.states = m.config.settings.screenStates
    m.screenMode = m.config.settings.screenMode
    m.screenClearMode = m.config.settings.screenCleanModes
    m.scene = getAppScene()
    'm.navigation = getAppScene().findNode("navigation")
end sub

sub onFocusChanged()
    hasFocus = m.top.hasFocus()
    if hasFocus then focusNode(m.screenStack)
end sub

function getScreenCount() as integer
    return m.screenStack.getChildCount()
end function

function getCurrentScreen() as object
    return m.screenStack.getChild(getScreenCount() - 1)
end function

function getPreviousScreen() as object
    return m.screenStack.getChild(getScreenCount() - 2)
end function

function searchScreen(screen as string) as dynamic
    result = invalid

    for i = 0 to m.screenStack.getChildCount() - 1
        stackScreen = m.screenStack.getChild(i)
        if stackScreen.id = screen then result = stackScreen
    end for

    return result
end function

sub addScreenToStack(screen as object)
    m.screenStack.appendChild(screen)
end sub

sub removeScreenFromStack(screen as object)
    screen.setField("state", m.states.closed)
    m.screenStack.removeChild(screen)
end sub

sub moveScreenToBottomOfStack(screen as object)
    m.screenStack.removeChild(screen)
    m.screenStack.appendChild(screen)
end sub

sub clearStack(context = {} as object)
    indexOffset = -1
    removeCount = m.screenStack.getChildCount()

    if context <> invalid and context.keepCurrent <> invalid and context.keepCurrent 'Remove all but current screen
        indexOffset--
        removeCount--
    end if

    for i=0 to m.screenStack.getChildCount() + indexOffset
        screen = m.screenStack.getChild(i)
        screen.setField("state", m.states.closed)
    end for

    m.screenStack.removeChildrenIndex(removeCount, 0)
end sub

sub disableScreen(screen as object, mode as string)
    if isValid(screen)
        if mode = m.screenMode.screen
            screen.state = m.states.sleep
        else if mode = m.screenMode.modal
            screen.state = m.states.inactive
        end if
    end if
end sub

function navigate(params as object) as boolean
    eventSuccess = false
    screenName = getValue(params, "screen", "")
    newScreenMode = getValue(params, "screenMode", m.screenMode.screen)
    nextScreen = searchScreen(screenName)
    currentScreen = getCurrentScreen()
    prevScreenName = getValue(currentScreen, "id", "")
    screenClearMode = getValue(params, "clearMode", "")

    if screenClearMode = m.screenClearMode.stack
        nextScreen = invalid
        clearStack()
    else if screenClearMode = m.screenClearMode.current
        removeScreenFromStack(currentScreen)
    end if

    if isValid(nextScreen) and (screenName = prevScreenName)
        'screen is active
        eventSuccess = true
    else if isValid(nextScreen)
        moveScreenToBottomOfStack(nextScreen)

        if currentScreen.id <> nextScreen.id
            disableScreen(currentScreen, newScreenMode)
        end if

        updateNavigationState(nextScreen)

        nextScreen.setField("state", m.states.revisit)
        eventSuccess = true
    else
        newScreen = m.screenStack.createChild(params.screen)

        if not isValid(newScreen) then return eventSuccess
        if isNullOrEmpty(screenClearMode) then disableScreen(currentScreen, newScreenMode)

        model = getValue(params, "model", invalid)
        setFocusOnInit = getValue(params, "setFocus", newScreen.setFocusOnInitState)
        
        updateNavigationState(newScreen)

        newScreen.setFocusOnInitState = setFocusOnInit
        newScreen.update({
            id: params.screen
            reqId: params.screen
            prevScreen: prevScreenName
            state: m.states.init
        })

        if isValid(model)
            newScreen.setField("model", model)
        end if

        eventSuccess = true
    end if

    return eventSuccess
end function

function navigateBack(context = {} as object) as boolean
    eventSuccess = false

    if getScreenCount() > 1
        currentScreen = getCurrentScreen()
        nextScreen = getPreviousScreen()

        removeScreenFromStack(currentScreen)
        updateNavigationState(nextScreen)
          
        if isValid(context) and context.count() > 0
            nextScreen.context = context
        end if

        nextScreen.setFields({
            state: m.states.navBack
        })

        eventSuccess = true
    end if

    return eventSuccess
end function

sub updateNavigationState(screen as object)
    'getAppScene().navigationEnabled = screen.enablesNavigation
    getAppScene().findNode("navigation").visible = screen.isSubtype("NavigableScreen")
end sub
