function createTransferObj(request as object) as object
    httpObj = CreateObject("roUrlTransfer")
    httpObj.SetCertificatesFile("common:/certs/ca-bundle.crt")
    httpObj.setUrl(injectProxy(request.url))
    httpObj.RetainBodyOnError(true)

    if isValid(request.headers)
        httpObj.setHeaders(request.headers)
    end if

    return httpObj
end function

function isSuccessfulResponseCode(code as integer) as boolean
    if code >= 200 and code < 300
        return true
    end if

    return false
end function

function createResponseNode(request, message = invalid, failure = "Bad request data")
    headers = ""
    body = ""
    code = ""
    wasSuccessful = false

    if isValid(message)
        failure = message.GetFailureReason()
        headers = message.GetResponseHeaders()
        body = message.GetString()
        code = message.GetResponseCode()
        wasSuccessful = isSuccessfulResponseCode(code)
    end if

    response = CreateObject("roSGNode", "ContentNode")
    response.update({
        wasSuccessful: wasSuccessful
        message: failure
        headers: headers
        body: body
        code: code
        requestId: getValue(request, "requestId", "")
        callerId: getValue(request, "callerId", "")
        reqFilters: getValue(request, "callerId", {})
    }, true)

    return response
end function

function createDefaultFailureResponseNode(failure = "Bad request data")
    return createResponseNode(invalid, invalid, failure)
end function

function createAdaptedResponseNode(message = invalid)
    failure = "Bad request data"
    headers = ""
    body = ""
    code = ""
    requestId = ""
    success = false

    if isValid(message)
        failure = message.GetFailureReason()
        headers = message.GetResponseHeaders()
        body = message.GetString()
        code = message.GetResponseCode()
        success = isSuccessfulResponseCode(code)
    end if

    response = CreateObject("roSGNode", "ContentNode")
    response.update({
        success: success
        message: failure
        headers: headers
        body: body
        code: code
    }, true)

    return response
end function

function createAdaptedDefaultFailureResponseNode(message = "Bad request data")
    return createAdaptedResponseNode(message)
end function

function injectProxy(url as string) as string
    #if proxy
        registrySection = getAppRegistrySection()
        proxyAddress = registrySection.read("proxyAddress")

        if proxyAddress <> "" then
            url = "http://" + proxyAddress + "/;" + url
        end if
    #end if

    return url
end function