sub init()
    m.httpTask = CreateObject("roSGNode", "HttpTask")
    m.top.videoSessionTimeStamps = CreateObject("roSGNode", "ContentNode")
    m.top.watchList = CreateObject("roSGNode", "ContentNode")
    m.top.user = CreateObject("roSGNode", "UserModel")
end sub

'*************************************************************************
'#region *** public functions
'*************************************************************************
'# Auth
sub getAccountInfo(accessToken as string)
    tokenType = iif(not isNullOrEmpty(m.top.user.tokenType), m.top.user.tokenType, "")
    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        path: "auth/AccountInfo"
        headers: {
            "Authorization": Substitute("{0} {1}", tokenType, m.top.user.accessToken)
        }
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.request = requestContext.callFunc("getRequest")
    requestNode.observeFieldScoped("response", "onGetAccountInfo")

    m.httpTask.requests = [requestNode]
end sub

sub getAuthToken(userCreds)
    authConfig = m.global.config.settings.auth
    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        envUrl: authConfig.url
        method: "POST"
        headers: {
            "Content-Type": "application/x-www-form-urlencoded"
        }
        body: {
            "grant_type": "password"
            "username": userCreds.user
            "client_id": authConfig.clientId
            "password": userCreds.password
            "scope": authConfig.scope
            "audience": authConfig.audience
        }
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.request = requestContext.callFunc("getRequest")
    requestNode.observeFieldScoped("response", "onGetAuthToken")

    m.httpTask.requests = [requestNode]
end sub

sub refreshAuthToken(refreshToken as string)
    authConfig = m.global.config.settings.auth
    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        envUrl: authConfig.url
        method: "POST"
        headers: {
            "Content-Type": "application/x-www-form-urlencoded"
        }
        body: {
            "grant_type": "refresh_token"
            "client_id": authConfig.clientId
            "refresh_token": refreshToken
        }
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.request = requestContext.callFunc("getRequest")
    requestNode.observeFieldScoped("response", "onRefreshAuthToken")

    m.top.user.refreshToken = refreshToken

    m.httpTask.requests = [requestNode]
end sub
'

'# Watchlist
function refreshWatchList()
    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        path: "watchlist/get"
        method: "POST"
        body: {
            "includeAll": false
        }
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.observeFieldScoped("response", "onGetWatchList")
    requestNode.request = requestContext.callFunc("getRequest")
    m.httpTask.requests = [requestNode]
end function

function getWatchList()
    return m.top.watchList
end function

function addToWatchList(videoId as integer)
    if not isInteger(videoId) then throw("Invalid Video ID")

    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        path: "watchlist/add"
        method: "POST"
        body: {
            "videoId": videoId
        }
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.observeFieldScoped("response", "onAddToWatchList")
    requestNode.request = requestContext.callFunc("getRequest")
    m.httpTask.requests = [requestNode]
end function

function removeFromWatchList(videoId as integer)
    if not isInteger(videoId) then throw("Invalid Video Id")

    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        path: "watchlist/delete"
        method: "DELETE"
        body: {
            "videoId": videoId
        }
    })

    getWatchList().removeField(videoId.toStr())

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.request = requestContext.callFunc("getRequest")
    m.httpTask.requests = [requestNode]
end function

'# Progress
function getVideoSessionProgress(session)
    if not isInteger(session.videoId) then throw("Invalid Video Id")
    if session.episodeId <> invalid and not isInteger(session.episodeId) then throw("Invalid Episode Id")

    progressId = getProgressId(session.videoId, session.episodeId)

    return m.top.videoSessionTimeStamps[progressId]
end function

function trackVideoSessionProgress(session)
    if not isInteger(session.timeStamp) then session.timeStamp = 0
    if not isInteger(session.videoId) then throw("Invalid Video Id")
    if session.episodeId <> invalid and not isInteger(session.episodeId) then throw("Invalid Episode Id")

    progressId = getProgressId(session.videoId, session.episodeId)

    if m.top.videoSessionTimeStamps[progressId] = invalid then m.top.videoSessionTimeStamps.addField(progressId, "int", false)

    m.top.videoSessionTimeStamps[progressId] = session.timeStamp

    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        path: "videosessions/videosession"
        method: "PUT"
        body: {
            "videoId": session.videoId,
            "episodeId": iif(session.episodeId > 0, session.episodeId, invalid),
            "timeStamp": session.timeStamp
        }
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.request = requestContext.callFunc("getRequest")
    m.httpTask.requests = [requestNode]
end function

'*************************************************************************
'#region *** Event callbacks
'*************************************************************************

sub onGetWatchList(evt)
    result = evt.getData()
    watchList = CreateObject("roSGNode", "ContentNode")

    if result.wasSuccessful
        for each wlItem in result?.content.getChildren(-1, 0)
            watchList.addField(wlItem.videoId.toStr(), "node", false)
            watchList.setField(wlItem.videoId.toStr(), wlItem)

            'keep item as a child as well to loop though children
            watchList.appendChild(wlItem)
        end for
    end if

    m.top.watchList = watchList
end sub

sub onAddToWatchList(evt)
    result = evt.getData()

    if result.wasSuccessful
        refreshWatchList()
    end if
end sub

'# Auth callbacks
sub onGetAuthToken(evt)
    result = evt.getData()

    authData = {
        "accessToken": ""
        "expiresIn": ""
        "refreshToken": ""
        "tokenType": ""
    }

    if result.wasSuccessful
        content = result.content

        authData["accessToken"] = content.access_token
        authData["refreshToken"] = content.refresh_token
        authData["expiresIn"] = content.expires_in
        authData["tokenType"] = content.token_type
    end if

    m.top.user.update(authData)
end sub

sub onRefreshAuthToken(evt)
    result = evt.getData()

    authData = {
        "accessToken": ""
        "expiresIn": ""
        "tokenType": ""
    }

    if result.wasSuccessful
        content = result.content

        authData["accessToken"] = content.access_token
        authData["expiresIn"] = content.expires_in
        authData["tokenType"] = content.token_type
    end if

    m.top.user.update(authData)
end sub

sub onGetAccountInfo(evt)
    result = evt.getData()

    account = {
        "afaToken": ""
    }

    if result.wasSuccessful
        content = result.content

        if isAssocArray(content.user)
            subscription = content.user?.subscription?.name
            account["profile"] = content.user
            account.profile["isGCP"] = isStr(subscription) <> invalid and ucase(subscription) = ucase("gcp")
            account["afaToken"] = content.user.Token
        end if
    end if

    m.top.user.update(account)
end sub

'*************************************************************************
'#region *** Utils
'*************************************************************************

function getProgressId(videoId as integer, episodeId as integer)
    progressId = videoId.toStr()

    if episodeId > 0 then progressId += episodeId.toStr()

    return progressId
end function