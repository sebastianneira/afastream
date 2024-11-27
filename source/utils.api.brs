
function createAdaptedRequestNode(request, responseCallBack = "")
    requestNode = createObject("roSGNode", "RequestNode")

    requestNode.request = request

    if responseCallBack <> ""
        requestNode.observeFieldScoped("response", responseCallBack)
    end if

    return requestNode
end function
