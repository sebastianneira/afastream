sub init()
    setComponents()
    setStyles()
    addObservers()
    initComponent()
end sub

sub setComponents()
    findNodes([
        "videoPlayer"
        "progressTimer"
    ])
end sub

sub setStyles()
    m.videoPlayer.update({
        width: 1920
        height: 1080
    })

    m.progressTimer.update({
        repeat: true
        duration: 45
    })
end sub

sub addObservers()
    m.progressTimer.observeField("fire", "onProgressTimerFired")
end sub

sub initComponent()
    m.lastTrackedProgress = invalid
    isScreenLoading(true)
end sub

sub onModelChanged(evt as dynamic)
    model = evt.getData()

    if isValid(model)
        m.isDeepLink = model.isDeepLink
        if not isNullOrEmpty(model.cloudflareVideoId)
            getVideoToken(model.cloudflareVideoId)
        else if model.isLive = true
            playLive(model)
        else
            navigateBack()
        end if
    else
        'invalid model
        navigateBack()
    end if
end sub

sub onVideoStateChanged(msg)
    state = msg.getData()

    if state = "error"
        navigateBack()
    else if state = "buffering"
        'showLoader()
    else if state = "playing"
        if not m.top.model.isTrailer
            'fire session tracking timer
            m.progressTimer.control = "start"
        end if
    else if state = "finished"
        ' delete the entry for the bookmark
        navigateBack()
    else if state = "stopped"
        if not m.top.model.isTrailer
            'fire session tracking timer
            m.progressTimer.control = "stop"
        end if
    else if state = "paused"
        
    end if
end sub


sub playVOD(token)
    playStart = 0

    if isValid(token)
        content = createObject("roSGNode", "ContentNode")
        progress = invalid

        if not m.top.model.isTrailer
            progress = createObject("roSGNode", "VideoProgressModel")
            progress.update({
                videoId: m.top.model.videoId
                episodeId: m.top.model.episodeId
            })

            'Get client-stored progress for the video, this takes precedence against the one stored in the model
            sessionMarker = m.global.userStateManager.callFunc("getVideoSessionProgress", progress)

            'fire session tracking timer
            m.progressTimer.control = "start"
        end if

        if not m.top.model.restartProgess
            if isValid(sessionMarker)
                playStart = sessionMarker
            else
                playStart = m.top.model.timeStamp
            end if
        end if

        content.update({
            title: iif(m.top.model.isTrailer, Substitute("{0} - {1}", tr("trailer"), m.top.model.title), m.top.model.title)
            ReleaseDate: m.top.model.airDateFormatted
            playStart: playStart
            streamformat: "HLS"
            url: Substitute("https://cloudflarestream.com/{0}/manifest/video.m3u8", token)
        }, true)

        m.videoPlayer.content = content
        m.videoPlayer.control = "play"

        focusNode(m.videoPlayer)
    else
        navigateBack()
    end if

    isScreenLoading(false)
end sub

sub playLive(model)
    content = createObject("roSGNode", "ContentNode")

    if isValid(model.liveUrl)
        content.update({
            title: tr("live") + ": " + model.title
            live: true
            streamformat: "HLS"
            url: model.liveUrl
        }, true)

        m.videoPlayer.content = content
        m.videoPlayer.control = "play"
    else
        navigateBack()
    end if

    isScreenLoading(false)
end sub

function getVideoToken(token)
    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        path: "auth/videoToken/" + token
        method: "GET"
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.request = requestContext.callFunc("getRequest")
    requestNode.observeFieldScoped("response", "onGetVideoToken")
    m.httpTask.requests = [requestNode]
end function

sub onGetVideoToken(evt)
    model = evt.getData()

    playVOD(model.content?.VideoToken)
end sub

sub onProgressTimerFired()
    if m.videoPlayer.state = "playing"
        m.lastTrackedProgress = CreateObject("roSGNode", "VideoProgressModel")
        m.lastTrackedProgress.update({
            timeStamp: cInt(m.videoPlayer.position)
            videoId: m.top.model.videoId
            episodeId: m.top.model.episodeId
        })

        m.global.userStateManager.callFunc("trackVideoSessionProgress", m.lastTrackedProgress)
    end if
end sub

function onKeyEvent(key, press) as boolean
    eventCaptured = false

    if not press return eventCaptured

    if key = "back"
        m.videoPlayer.control = "stop"
        navigateBack(m.lastTrackedProgress)
        eventCaptured = true
    end if

    return eventCaptured
end function
