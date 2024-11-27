function handleAPIResponse(request, response)
    result = invalid

    if response.success
        result = CreateObject("roSGNode", "ResponseNode")
        responseMessage = response.body

        if isNullOrEmpty(responseMessage) then return result

        response = ParseJson(responseMessage)
        requestParser = request.parser

        if requestParser = "search" and response.videos <> invalid
            response = response.videos
        else if requestParser = "episodespage"
            response = { items: response }
        end if

        if isAssocArray(response)
            result.content.update(response, true)
        else if isArray(response)
            for each item in response
                child = CreateObject("roSGNode", "ContentNode")
                child.update(item, true)
                result.content.appendChild(child)
            end for
        end if
    end if

    if result = invalid
        result = CreateObject("roSGNode", "ResponseNode")
        result.wasSuccessful = false
    end if

    return result
end function