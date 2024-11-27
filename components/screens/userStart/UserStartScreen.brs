sub init()
    initComponent()
end sub

sub initComponent()
    m.authToken = ""
    m.requiresLogin = false
end sub

sub onModelChanged(evt as dynamic)
    ' model = evt.getData()

    ' 'profile is always loaded to refresh latest from server
    ' if isValid(model)
    '     m.navigateBack  = getValue(model, "navigateBack", false)
    '     m.authToken = getValue(model, "token", "")
    ' end if

    ' if not isNullOrEmpty(m.authToken)
    '     updateUserToken(m.authToken)
    ' else
    '     m.authToken = m.global.authToken
    ' end if
end sub

function onKeyEvent(key, press) as boolean
    'block keyboard events
    return true
end function
