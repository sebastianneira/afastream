sub init()
    _setComponents()
    _addObservers()
    _initComponent()
end sub

sub _initComponent()
    m.top.focusable = true

    m.tmrKeyHoldLock.duration = 0.35
    m.tmrKeyHold.repeat = true
    m.tmrKeyHold.duration = 0.10

    setFocusedIndex(-1)
end sub

sub _addObservers()
    m.top.observeField("enabled", "_onEnabledChanged")
    m.top.observeField("focusedChild", "_onFocusChanged")
    m.top.observeField("resetIndex", "_onResetIndexChanged")
    m.top.observeField("forceFocus", "_onForceFocusChanged")
    m.top.observeField("keyHoldLockDuration", "_onHoldLockDurationChanged")
    m.top.observeField("keyHoldDuration", "_onKeyHoldDurationChanged")
    m.tmrKeyHoldLock.observeField("fire", "_onKeyHoldLockFired")
    m.tmrKeyHold.observeField("fire", "_onKeyHoldFired")
end sub

sub _setComponents()
    m.tmrKeyHoldLock = CreateObject("roSGNode", "Timer")
    m.tmrKeyHold = CreateObject("roSGNode", "Timer")
end sub

sub _onForceFocusChanged(evt as dynamic)
    nodeName = evt.getData()
    'Force initial focused element
    if not isEmpty(nodeName)
        setFocusedIndex(findNodeIndex(nodeName))
        focusCurrent()
    end if
end sub

sub _onFocusChanged(evt as dynamic)
    if m.top.hasFocus()
        focusCurrent()
        'if isValid(onFocusChanged) then onFocusChanged()
    else if not m.top.isInFocusChain()
        if not m.top.keepIndex then setFocusedIndex(-1)
        setKeyRelease()
    end if
end sub

sub _onResetIndexChanged(evt as dynamic)
    setFocusedIndex(-1)
end sub

sub _onEnabledChanged(evt as dynamic)
    enabled = evt.getData()

    if not enabled then setKeyRelease()
end sub

sub _onHoldLockDurationChanged(evt as dynamic)
    value = evt.getData()
    m.tmrKeyHoldLock.duration = value
end sub

sub _onKeyHoldDurationChanged(evt as dynamic)
    value = evt.getData()
    m.tmrKeyHold.duration = value
end sub

sub _onKeyHoldFired()
    ?"_onKeyHoldFired " m.top.alias
    if isValid(m.currentAction)
        m.top.keyHoldInProgress = true
        m.currentAction()
    end if
end sub

sub _onKeyHoldLockFired()
    ?"_onKeyHoldLockFired"
    m.tmrKeyHold.control = "start"
end sub

sub focusCurrent()
    if m.focusedIndex = -1
        focusNext()
    else
        selectedChild = m.top.getChild(m.focusedIndex)
        if isValid(selectedChild)
            focusNode(selectedChild)
        else
            setFocusedIndex(-1)
            focusNext()
        end if
    end if
end sub

sub setFocusedIndex(index = 0)
    m.focusedIndex = index
    m.top.focusedIndex = index
end sub

sub setKeyHold(action as function)
    m.currentAction = action
    m.tmrKeyHoldLock.control = "start"
end sub

sub setKeyRelease()
    m.currentAction = invalid
    m.top.keyHoldInProgress = false
    m.tmrKeyHoldLock.control = "stop"
    m.tmrKeyHold.control = "stop"
end sub

function setFocused(context = {} as object)
    index = getValue(context, "index", -1)
    nodeId = getValue(context, "id")
    pasiveFocus = getValue(context, "pasiveFocus", false)

    if index >= 0
        setFocusedIndex(index)
    else if not isNullOrEmpty(nodeId)
        setFocusedIndex(findNodeIndex(nodeId))
    end if

    if not pasiveFocus then focusCurrent()
end function

function onKeyEvent(key, press) as boolean
    ?"ELG PRESS " action
    eventCaptured = false
    action = m.keyAction[key]

    if action = invalid or not m.top.enabled
        return false
    end if

    if not press and not m.top.keyHoldAllowed
        return false
    end if

    if m.top.keyHoldAllowed
        if press    
            setKeyHold(action)
            return action()
        else
            setKeyRelease()
        end if
    else
        return action()
    end if

    return eventCaptured
end function
