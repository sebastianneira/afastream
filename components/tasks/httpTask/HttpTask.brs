sub init()
    m.port = CreateObject("roMessagePort")

    m.top.observeField("requests", m.port)
    m.top.observeField("endTask", m.port)
    
    m.top.functionName = "initTask"
    m.top.control = "RUN"
end sub

sub initTask()
    m.httpMessageQueue = {}

    while true
        message = wait(0, m.port)

        if type(message) = "roUrlEvent"
            identity = message.GetSourceIdentity().toStr()
            httpEvent = m.httpMessageQueue[identity]
            
            finishPerformanceTracking()
            
            httpEvent.reqContext.callfunc("handleResponse", createAdaptedResponseNode(message))
            
            m.httpMessageQueue.delete(identity)
          
            if m.httpMessageQueue.Count() = 0 
                m.top.queueCompleted = true
            end if
        else if type(message) = "roSGNodeEvent"
            if message.getField() = "requests"
                requests = message.getData()
                for each requestNode in requests
                    makeHttpRequest(requestNode)
                end for
            else if message.getField() = "endTask"
                return
            end if
        end if
    end while
end sub

sub makeHttpRequest(requestNode)
    callSuccess = false
    request = requestNode.request

    if isValid(request)
        requestType = UCase(request.method)
        httpRequest = createTransferObj(request)
        httpRequest.setMessagePort(m.port)
        identity = httpRequest.GetIdentity().toStr()
        body = request.body
        remainingAttempts = 3
        
        startPerformanceTracking("HttpTask Making HTTP Request: " + request.url)

        if isAssocArray(body) then
            body = formatJson(request.body)
        end if
        
        while not callSuccess and remainingAttempts > 0
            if requestType = "GET"
                callSuccess = httpRequest.AsyncGetToString()
            else if requestType = "POST"
                callSuccess = httpRequest.AsyncPostFromString(body)
            else if requestType = "PUT" or requestType = "PATCH" then
                httpRequest.setRequest(requestType)
                callSuccess = httpRequest.AsyncPostFromString(body)
            else if requestType = "DELETE"
                httpRequest.setRequest("DELETE")

                if isStr(body) then
                    callSuccess = httpRequest.AsyncPostFromString(body)
                else
                    callSuccess = httpRequest.AsyncGetToString()
                end if
            end if

            remainingAttempts--
        end while
    end if

    if callSuccess
        m.httpMessageQueue[identity] = { transferObj: httpRequest, reqContext: requestNode }
    else
        requestNode.response = createAdaptedDefaultFailureResponseNode()
    end if
end sub