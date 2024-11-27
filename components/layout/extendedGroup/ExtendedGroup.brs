sub init()
    _initComponent()
    _addObservers()
end sub

sub _initComponent()
    m.initChildren = m.top.getChildCount()
    m.top.focusable = true
    m.keyAction = {}

    setFocusedIndex(-1)
end sub

sub _addObservers()
    m.top.observeField("focusedChild", "_onFocusChanged")
    m.top.observeField("forceFocus", "_onForceFocusChanged")
end sub

sub _onFocusChanged(evt as dynamic)
    '?"BASE GROUP _onFocusChanged : " m.top.id " hasFocus " m.top.hasFocus() " isInChain: " m.top.isInFocusChain() " index " m.focusedIndex
    if m.top.hasFocus()
        'Force initial focused element, otherwise looks for first focusable
        if not isEmpty(m.top.forceFocus)
            setFocusedIndex(findNodeIndex(m.top.forceFocus))
        end if

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

        'if isValid(onFocusChanged) then onFocusChanged()
    else if not m.top.isInFocusChain()
        if not m.top.keepIndex then setFocusedIndex(-1)
    end if
end sub

sub _onForceFocusChanged(evt as dynamic)
    nodeName = evt.getData()
    'Force initial focused element
    if not isEmpty(nodeName)
        setFocusedIndex(findNodeIndex(nodeName))
        focusCurrent()
    end if
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
    m.top.focusedIndex = index - m.initChildren
end sub

function onKeyEvent(key, press) as boolean
    if not press then return false

    action = m.keyAction[key]
    if action <> invalid
        return action()
    end if

    return false
end function
