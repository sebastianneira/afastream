sub init()
    m.httpTask = CreateObject("roSGNode", "HttpTask")
    m.dateTime = invalid
    m.top.liveStreamUrl = ""
end sub

'*************************************************************************
'#region *** public functions
'*************************************************************************

function getLiveShows()
    loadLiveStream()
    'loadLiveShowDetail(1950)
end function

function loadLiveStream()
    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        envUrl: "https://player-backend.restream.io/"
        path: "public/videos/1c9e5e24d5084ed5b994000a8bed5a9b"
        method: "GET"
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.observeFieldScoped("response", "onGetLiveStream")
    requestNode.request = requestContext.callFunc("getRequest")
    m.httpTask.requests = [requestNode]
end function

function getLiveShowsTimeZone()
    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        envUrl: "http://worldtimeapi.org/api/timezone/America/Chicago"
        method: "GET"
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.observeFieldScoped("response", "onGetLiveShowsTimeZone")
    requestNode.request = requestContext.callFunc("getRequest")
    m.httpTask.requests = [requestNode]
end function

function loadLiveShows()
    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        path: "video/LiveStreams"
        method: "GET"
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.observeFieldScoped("response", "onGetLiveShows")
    requestNode.request = requestContext.callFunc("getRequest")
    m.httpTask.requests = [requestNode]
end function

function loadLiveShowDetail(id)
    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        path: "video/videodetails/" + id.toStr()
        method: "GET"
    })
    
    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.request = requestContext.callFunc("getRequest")
    requestNode.observeFieldScoped("response", "onGetLiveShowDetail")
    m.httpTask.requests = [requestNode]
end function

'*************************************************************************
'#region *** Event callbacks
'*************************************************************************
sub onGetLiveStream(evt)
    result = evt.getData()

    if result.wasSuccessful
        content = result.content
        if content.videoUrlHls <> invalid
            m.top.liveStreamUrl = content.videoUrlHls
            getLiveShowsTimeZone()
        end if
    else
        m.top.liveStreamUrl = ""
    end if
end sub

sub onGetLiveShowsTimeZone(evt)
    result = evt.getData()

    if result.wasSuccessful
        if result?.content?.datetime <> invalid
            dateTime = CreateObject("roDateTime")
            dateTime.FromISO8601String(result.content.datetime)
            
            m.dateTime = dateTime
        end if
    end if

    if m.dateTime = invalid then m.dateTime = CreateObject("roDateTime")

    loadLiveShows()
end sub

sub onGetLiveShows(evt)
    result = evt.getData()

    if result.wasSuccessful
        try
            currentTime = m.dateTime.getHours().toStr() + m.dateTime.getMinutes().toStr()
            currentTime = val(currentTime)
            for each child in result.content.getChildren(-1, 0)
                startTime = val(child.startTime.replace(":", ""))
                endTimeTime = val(child.endTime.replace(":", ""))

                if currentTime >= startTime and currentTime <= endTimeTime
                    loadLiveShowDetail(child.id)
                end if
            end for
        catch e
        end try
    end if
end sub

sub onGetLiveShowDetail(evt)
    result = evt.getData()

    if result.wasSuccessful
        try
            liveShow = CreateObject("roSGNode", "ContentNode")
            detail = result.content.video
            imageUri = result.content?.episodes?[0]?.episode?.image

            if imageUri = invalid 
                imageUri = detail.rotatorImages?[0].url
            end if

            liveShow.update({
                videoId: detail.id
                heading: detail.title
                content: detail.summary
                backgroundImage: iif(imageUri <> invalid, imageUri, "")
                isLive: true
                liveUrl: m.top.liveStreamUrl
            }, true)
            
            m.top.liveStreamShow = liveShow
        catch e
        end try
    end if
end sub