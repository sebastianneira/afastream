sub init()
    m.top.method = "GET"
    m.top.parser = ""
    m.top.headers = {}
    m.top.query = {}
    m.top.body = {}
    m.top.additionalInfo = {}
    m.top.requiresAuth = true
    m.top.queryEncode = true
    m.top.envUrl = m.global.environmentAPIUrl
end sub

function validate()
    return not isNullOrEmpty(m.top.resource) and not isValidMethod(m.top.method)
end function

' /**
' * @builds the path using request context
' * @return {String} Full request path
' */
function getUrl()
    requestType = ""
    queryString = ""
    path = ""

    if m.top.query.count() > 0 
        queryString = mapObjectToQueryString(m.top.query, m.top.queryEncode, true)
    end if
    
    return m.top.envUrl + m.top.path + queryString
end function

function getRequest()
    headers = m.top.headers
    body = iif(m.top.body.count() > 0, m.top.body, {})
    user = m.global.userStateManager.user

    if headers["Content-Type"] = invalid
        headers["Content-Type"] = "application/json"
    end if

    'Add default auth header
    if headers["Authorization"] = invalid and m.top.envUrl = m.global.environmentAPIUrl
        headers["Authorization"] = Substitute("{0} {1}", user.tokenType, user.afaToken)
    end if

    if headers["Content-Type"] = "application/x-www-form-urlencoded"
        body = mapObjectToQueryString(body)
    end if

    return {
        url: getUrl()
        headers: headers
        body: body
        parser: LCase(m.top.parser)
        method: iif(not isEmpty(m.top.method), m.top.method, "GET")
        context: {
            environmentUrl: m.top.envUrl
            path: m.top.path
        }
    }
end function

function isValidMethod(method)
    method = ucase(method)
    return method = "GET" or method = "POST" or method = "PUT" or method = "DELETE"
end function