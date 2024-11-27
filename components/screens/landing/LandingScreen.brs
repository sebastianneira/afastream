sub init()
    setComponents()
    setStyles()
    addObservers()
    initComponent()
end sub

sub setComponents()
    findNodes([
        "container"
        "logo"
        "title"
        "description"
        "email"
        "password"
        "btnContinue"
        "errorMsg"
        "keyboard"
        "store"
    ])
end sub

sub setStyles()
    vertSpacing = 21
    horizSpacing = 30
    m.container.update({
        horizAlignment: "center"
        vertAlignment: "center"
        translation: [960, 465] '373
        itemSpacings: [39, 30, 36, 18, 12, 9]
    })

    m.logo.update({
        width: 663
        height: 126
        uri: "pkg:/images/brand/afa-logo-long.png"
    })

    m.title.update({
        text: tr("welcome")
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 39
        }
        maxLines: 1
        color: "0xCCCCCC"
    })

    m.description.update({
        text: tr("logInMessage")
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 21
        }
        maxLines: 2
        wrap: true
        width: 360
        color: "0xCCCCCC"
    })

    m.email.update({
        hint: tr("email")
        width: 600
        height: 60
    })

    m.password.update({
        hint: tr("password")
        isSecureField: true
        width: 600
        height: 60
    })

    m.errorMsg.update({
        text: tr("login_validation")
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 18
        }
        horizAlign: "center"
        maxLines: 1
        wrap: false
        width: 600
        color: "0xFE5F55"
        visible: false
    })

    m.btnContinue.update({
        text: tr("continue")
        flexible: false
        maxWidth: 300
    })
end sub

sub addObservers()
    m.email.observeField("selected", "onInputFieldSelected")
    m.password.observeField("selected", "onInputFieldSelected")
    m.btnContinue.observeField("selected", "onBtnContinueSelected")
    m.keyboard.observeField("text", "onKeyboardTextChanged")
    m.store.observeField("userData", "onGetUserData")
end sub

sub initComponent()
    hideKeyboard()

    m.email.update({
        validationMsg: tr("email_validation")
        regex: "^[A-Za-z0-9_%+-]+(\.[A-Za-z0-9_%+-]+)*@([A-Za-z0-9-]+\.)+[A-Za-z]{2,6}$"
    })
    m.password.validationMsg = tr("password_validation")

    storeDataInfo = CreateObject("roSGNode", "ContentNode")
    storeDataInfo.update({ context: "signin" }, true)
    m.store.requestedUserData = "email"
    m.store.requestedUserDataInfo = storeDataInfo

    if m.isDebug = true
        ' m.email.text = "rhdez.g@gmail.com"
        ' m.password.text = "Qwerty@123"

        m.email.text = "developer@afa.net"
        m.password.text = "testerPassword2023!#"


        ' m.email.text = "jarrod.Glasgow@gmail.com"
        ' m.password.text = "neXxej-jusme6"

        ' m.email.text = "kaley@belovedrobot.com"
        ' m.password.text = "Test123!"
    else
        m.store.command = "getUserData"
    end if
end sub

sub showKeyboard(node)
    m.keyboard.update({
        node: node
        context: { text: node.text }
        visible: true
    })

    focusNode(m.keyboard)
end sub

sub hideKeyboard()
    m.keyboard.visible = false
end sub

sub setContinueState(status)
    m.btnContinue.enabled = status
    m.errorMsg.visible = status

    isScreenLoading(not status)
end sub

sub getAuthToken(user as string, password as string)
    m.global.userStateManager.user.observeField("accessToken", "onGetAccessToken")
    m.global.userStateManager.callFunc("getAuthToken", { user: user, password: password })
end sub

sub onGetAccessToken(evt)
    accessToken = evt.getData()

    if not isNullOrEmpty(accessToken)
        m.global.userStateManager.user.unObserveField("accessToken")
        m.global.userStateManager.user.observeField("afaToken", "onGetAFAToken")

        m.global.userStateManager.callFunc("getAccountInfo", accessToken)
    else
        setContinueState(true)
    end if
end sub

sub onGetAFAToken(evt)
    afaToken = evt.getData()

    if not isNullOrEmpty(afaToken)
        registryWrite("user", m.global.userStateManager.user.refreshToken)

        m.global.userStateManager.observeField("watchList", "onWatchListReady")
        m.global.userStateManager.callFunc("refreshWatchList")
    else
        setContinueState(true)
    end if
end sub

sub onScreenInit()
    focusNode(m.container)
    fireAppDialogLaunch()
end sub

sub onScreenFocusChanged(evt)
end sub

sub onInputFieldSelected(evt)
    showKeyboard(evt.getRoSgNode())
end sub

sub onKeyboardTextChanged(evt)
    if m.keyboard.node <> invalid
        m.keyboard.node.text = evt.getData()
    end if
end sub

sub onBtnContinueSelected()
    validEmail = m.email.callFunc("validate")
    validPassword = m.password.callFunc("validate")

    if validEmail and validPassword
        setContinueState(false)
        getAuthToken(m.email.text, m.password.text)
    end if
end sub

sub onWatchListReady()
    fireAppDialogComplete()
    fireREDTrackEvent("Roku_Authenticated")
    clearStackAndNavigate("HomeScreen")
end sub

sub onGetUserData(evt)
    userData = evt.getData()
    if isValid(userData)
        m.email.text = iif(userData.email <> invalid, userData.email, "")
    end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    eventCaptured = false

    if not press then return eventCaptured

    if key = "up" and m.keyboard.isInFocusChain()
        hideKeyboard()
        focusNode(m.container)
        eventCaptured = true
    else if key = "down" and m.container.isInFocusChain()
        focusNode(m.keyboard)
        eventCaptured = true
    else if key = "back"
        if m.keyboard.isInFocusChain()
            hideKeyboard()
            focusNode(m.container)
            eventCaptured = true
        end if
    end if

    return eventCaptured
end function