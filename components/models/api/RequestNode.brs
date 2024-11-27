sub init()
end sub

function handleResponse(httpResponse)
    startPerformanceTracking("Parsing response callback: ")
    model = handleAPIResponse(m.top.request, httpResponse)
    finishPerformanceTracking()

    m.top.response = model
end function