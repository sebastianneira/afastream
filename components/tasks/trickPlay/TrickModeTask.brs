sub init()
    m.port = createObject("roMessagePort")

    m.top.observeField("request", m.port)
    m.top.observeFieldScoped("endTask", m.port)

    m.top.functionName = "initTask"
    m.top.control = "RUN"
end sub

sub initTask()
    m.httpMessageQueue = {}

    while true
        message = wait(0, m.port)
        messageType = type(message)
        if messageType = "roUrlEvent"
            identity = message.GetSourceIdentity().toStr()
            httpEvent = m.httpMessageQueue[identity]
            request = httpEvent.requestor.request

            content = createResponseNode(request, message)

            if isValid(httpEvent.requestor.response)
                httpEvent.requestor.response = parseThumbnailStamps(content.body)
            end if

            'delete message from queue
            m.httpMessageQueue.delete(identity)
        else if messageType = "roSGNodeEvent"
            field = message.getField()
            if field = "request" then
                context = message.getData()
                makeHttpRequest(context.reqNode)
            else if field = "endTask" then
                return
            end if
        end if
    end while
end sub

sub makeHttpRequest(requestNode)
    request = requestNode.request
    httpRequest = createTransferObj(request)
    httpRequest.setMessagePort(m.port)
    identity = httpRequest.GetIdentity().toStr()

    m.httpMessageQueue[identity] = { id: requestNode.request.requestId,
        transferObj: httpRequest, requestor: requestNode }

    callSuccess = httpRequest.AsyncGetToString()

    if not callSuccess
        requestNode.response = createDefaultFailureResponseNode()
    end if
end sub

'parses WEBVTT file with the following format:
'00:00.000 --> 00:05.000
'{imageUrl}
function parseThumbnailStamps(body)
    result = CreateObject("roSGNode", "ContentNode")
    itemRegexPattern= "(?m)^(\d{2}:\d{2}\.\d+) +--> +(\d{2}:\d{2}\.\d+).*[\r\n]+\s*(?s)((?:(?!\r?\n\r?\n).)*)"
    timeStampPattern = "^(\d{2}):(\d{2})(\.\d+)"
    itemsRegex = CreateObject("roRegex", itemRegexPattern, "")
    timeStampsRgex = CreateObject("roRegex", timeStampPattern, "")
    thumbnails = []

    items = itemsRegex.MatchAll(body)

    for each item in items
        addValue = false
        minTime = timeStampsRgex.Match(item[1])
        maxTime = timeStampsRgex.Match(item[2])
        url = ""

        if hasElements(minTime) and hasElements(maxTime) and isValid(item[3])
            minTimeSecs = val(minTime[1]) * 60 + val(minTime[2])
            maxTimeSecs = val(maxTime[1]) * 60 + val(maxTime[2])
            url = item[3]
            addValue = true
        end if

        if addValue
            thumbnails.push({
                startTime: minTimeSecs
                endTime: maxTimeSecs
                imageUrl: url
            })
        end if
    end for

    result.update({ "content": thumbnails }, true)

    return result
end function
