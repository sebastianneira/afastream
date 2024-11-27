sub init()
    m.deeplinkData = m.global.deeplink
    m.languageReady = false
    m.experimentsReady = false
end sub

sub onScreenInit()
    isScreenLoading()
    registryRead("user", "onUserRead")
end sub

sub goToLandingPage()
    registryDelete("user")
    clearStackAndNavigate("LandingScreen")
end sub

sub onUserRead(msg)
    result = msg.getData()

    if result.wasSuccessful and not isNullOrEmpty(result.value)
        ' 'Refresh user token, and restore profile info
        refreshToken = result.value
        m.global.userStateManager.user.observeField("accessToken", "onGetAccessToken")
        m.global.userStateManager.callFunc("refreshAuthToken", refreshToken)
    else
        goToLandingPage()
    end if
end sub

sub onGetAccessToken(evt)
    accessToken = evt.getData()

    ?"ACCESS TOKEN"
    ?accessToken
    if not isNullOrEmpty(accessToken)
        m.global.userStateManager.user.unObserveField("accessToken")
        m.global.userStateManager.user.observeField("afaToken", "onGetAFAToken")
        m.global.userStateManager.callFunc("getAccountInfo", accessToken)
    else
        goToLandingPage()
    end if
end sub

sub onGetAFAToken(evt)
    afaToken = evt.getData()

    ?"AFA TOKEN"
    ?afaToken
    if not isNullOrEmpty(afaToken)
        m.global.userStateManager.observeField("watchList", "onWatchListReady")
        m.global.userStateManager.callFunc("refreshWatchList")
    else
        goToLandingPage()
    end if
end sub

sub onWatchListReady()
    fireREDTrackEvent("Roku_Authenticated")

    if m?.deeplinkData?.id <> invalid
        'm.deeplinkData = { id: 2266 }
        clearStackAndNavigate("DetailScreen", { videoId: m.deeplinkData.id, isDeepLink: true, instantPlay: true })
    else
        clearStackAndNavigate("HomeScreen")
    end if
end sub

function onKeyEvent(key, press) as boolean
    'block keyboard events
    return true
end function
