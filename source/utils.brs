'*************************************************************************
'#region *** TYPE CHECKING
'*************************************************************************

' /**
' * @description Checks if the supplied value is a valid Integer type
' * @param {Dynamic} value The variable to be checked
' * @return {Boolean} Results of the check
' */
function isInteger(value as Dynamic) as Boolean
	valueType = type(value)
	return (valueType = "Integer") OR (valueType = "roInt") OR (valueType = "roInteger") OR (valueType = "LongInteger")
end function

' /**
' * @description Checks if the supplied value is a valid Float type
' * @param {Dynamic} value The variable to be checked
' * @return {Boolean} Results of the check
' */
function isFloat(value as Dynamic) as Boolean
	valueType = type(value)
	return (valueType = "Float") OR (valueType = "roFloat")
end function

' /**
' * @description Checks if the supplied value is a valid Double type
' * @param {Dynamic} value The variable to be checked
' * @return {Boolean} Results of the check
' */
function isDouble(value as Dynamic) as Boolean
	valueType = type(value)
	return (valueType = "Double") OR (valueType = "roDouble") OR (valueType = "roIntrinsicDouble")
end function

' /**
' * @description Checks if the supplied value is a valid number type
' * @param {Dynamic} value The variable to be checked
' * @return {Boolean} Results of the check
' */
function isNumber(value as Dynamic) as Boolean
	if isInteger(value) then return true
	if isFloat(value) then return true
	if isDouble(value) then return true
	return false
end function

' * @description Checks if the supplied value is a valid Boolean type
' * @param {Dynamic} value The variable to be checked
' * @return {Boolean} Results of the check
' */
function isBoolean(value as Dynamic) as Boolean
	valueType = type(value)
	return (valueType = "Boolean") OR (valueType = "roBoolean")
end function

' /**
' * @description Checks if the supplied value is String
' * @param {Dynamic} value The variable to be checked
' * @return {Boolean} Results of the check
' */
function isStr(value)
    return (value <> invalid) and (GetInterface(value, "ifString") <> invalid)
end function

' /**
' * @description Checks if the supplied value is valid and empty string
' * @param {Dynamic} value The variable to be checked
' * @return {Boolean} Results of the check
' */
function isEmpty(value as Dynamic) as Boolean
    return isStr(value) and value = ""
end function

' /**
' * @description Checks if the supplied value isn't empty string
' * @param {Dynamic} value The variable to be checked
' * @return {Boolean} Results of the check
' */
function isNonEmptyString(value as Dynamic) as Boolean
    return isStr(value) AND value <> ""
end function

' /**
' * @description Checks if the supplied value is null or an empty string
' * @param {Dynamic} value The variable to be checked
' * @return {Boolean} Results of the check
' */
function isNullOrEmpty(value)
    return type(value) = "<uninitialized>" or (value = invalid) or not isstr(value) or Len(value) = 0
end function

' /**
' * @description Checks if the supplied value is a valid AssociativeArray type
' * @param {Dynamic} value The variable to be checked
' * @return {Boolean} Results of the check
' */
function isAssocArray(value as Dynamic) as Boolean
	return type(value) = "roAssociativeArray"
end function

' /**
' * @description Checks if the supplied value is a valid Node type
' * @param {Dynamic} value The variable to be checked
' * @return {Boolean} Results of the check
' */
function isNode(value as Dynamic) as Boolean
	return type(value) = "roSGNode"
end function

' /**
' * @description Checks if the supplied value is Array type
' * @param {Dynamic} value The variable to be checked
' * @return {Boolean} Results of the check
' */
function isArray(value as Dynamic) as Boolean
    return type(value) = "roArray"
end function

' /**
' * @description Checks if the supplied value is a valid AssociativeArray type with key values
' * @param {Dynamic} value The variable to be checked
' * @return {Boolean} Results of the check
' */
function isArrayWithKeys(value as Dynamic) as Boolean
    return type(value) = "roAssociativeArray" and value.Count() > 0
end function

' /**
' * @description Checks if the supplied value is a valid Function type
' * @param {Dynamic} value The variable to be checked
' * @return {Boolean} Results of the check
' */
function isFunction(value as Dynamic) as Boolean
	valueType = type(value)
	return (valueType = "roFunction") OR (valueType = "Function")
end function

' /**
' * @description Checks if the supplied value is initialized and valid
' * @param {Dynamic} value The variable to be checked
' * @return {Boolean} Results of the check
' */
function isValid(value as Dynamic) as Boolean
    return type(value) <> "<uninitialized>" AND value <> invalid
end function

' /**
' * @description Checks if the supplied value is initialized and valid
' * @param {Boolean} Expression to evaluate
' * @param {Dynamic} First option
' * @param {Dynamic} Second option
' * @return {Dynamic} Returns first option if condition true, otherwise returns second option
' */
function iif(condition as boolean, option1 as dynamic, option2 as dynamic)
    result = option1

    if isValid(condition) and isBoolean(condition) and not condition result = option2

    return result
end function
'*************************************************************************
'#region *** Associative Array utils
'*************************************************************************

' /**
' * @description Creates a copy of an associative array
' * @param {Object} value the AA to be copied
' * @param {Boolean} include AA sub elements
' * @return {Object} Result AA
' */
function copyAssocArray(value as Object, deepCopy = false as Boolean) as Object
    result = {}

    if not isAssocArray(value) return value

    result.append(value)
    
    if deepCopy then
        for each key in result
            result[key] = copyAssocArray(result[key])
        end for
    end if

    return result
end function

' /**
' * @description Copy and extends an AA
' * @param {Object} source the array to be extended
' * @param {Object} array to be used
' * @return {Object} New Associative Array
' */
function extendAssocArray(source as object, newObject as object)
    result = copyAssocArray(source)

    for each property in newObject
        result[property] = newObject[property]
    end for

    return result
end function

' /**
' * @description Remove keys from an AA
' * @param {Object} AA to remove key values
' * @param {Object} AA of keys with properties names to be removed
' * @return {Object} New Associative Array
' */
function removeAssocArrayKeys(value, keys)
    if not isAssocArray(value) return {}
    if not hasElements(keys) return value
    
    for each key in keys
        value.delete(key)
    end for

    return value
end function

'*************************************************************************
'#region *** Array utils
'*************************************************************************

' /**
' * @description Creates a copy of an array
' * @param {Object} value the array to be copied
' * @return {Object} Result array
' */
function copyArray(value as Object) as Object
    result = []
    if not isArray(value) return result
    result.append(value)
    return result
end function

' /**
' * @description Checks if the provided object is an array and has elements
' * @param {Object} source the array to remove key values
' * @return {Object} Boolean
' */
function hasElements(value as Dynamic) as Boolean
    return isValid(value) and type(value) = "roArray" and value.count() > 0
end function

function arrayToString(input as object, separator = ", " as string)
    result = ""

    for each word in input
        result += toString(word) + separator
    end for

    result = left(result, len(result) - len(separator))

    return result
end function

function getItemFromArrayByProp(array, property, value)
    result = invalid

    if not isValid(array) and not isNullOrEmpty(value) and not isNullOrEmpty(property) then return result

    for each item in array
        if item[property] = value
            result = item
            exit for
        end if
    end for

    return result
end function

function getItemFromArrayByProps(array, properties)
    result = invalid

    if not isArray(array) or not isAssocArray(properties) then return result

    for each item in array
        itemMatches = true

        for each prop in properties.Items() 
            ?">>>> key " prop.key " value:: " prop.value " equals? " item[prop.key] = toString(prop.value)
            itemMatches = item.doesExist(prop.key) and item[prop.key] = toString(prop.value)
        end for

        if itemMatches 
            result = item
            exit for
        end if
    end for

    return result
end function

function existsInCollection(collection, value)
    result = false

    if not isValid(collection) or isNullOrEmpty(value) then return result

    for each item in collection
        if item = value
            result = true
            exit for
        end if
    end for

    return result
end function

function getLastArrayIndex(array as Object) as Integer
    return array.count() - 1
end function

'*************************************************************************
'#region *** Misc
'*************************************************************************

function getValue(input as Dynamic, path = "" as String, defaultVal = invalid as Dynamic) as Dynamic
    if (type(input) = "<uninitialized>" OR input = invalid OR path = "") return defaultVal

    result = input
    keys = path.tokenize(".")

    if keys.count() > 0
       for each key in keys
            if isNode(result) or isAssocArray(result)
                result = result[key]
                if result = invalid then return defaultVal
            else
                return result
            end if
       end for
    end if

   return result
end function

function getValueueOrDefault(value, default)
    return iif(not value = invalid, value, default)
end function

function mapObjectToQueryString(data = invalid as Object, encode = false as boolean, addQuestionMark = false as boolean) as String
    result = ""

    if isAssocArray(data)
        for each item in data.Items()
            value = item.value

            if not isStr(item.value) 
                value = toString(value)
            end if

            result += item.key + "=" + iif(encode, value.EncodeUriComponent(), value) + "&"
        end for
        
        result = left(result, len(result) - 1) 
    end if

    if not isNullOrEmpty(result) and addQuestionMark then result = "?" + result

    return result
end function

function durationToSeconds(duration = "" as String) as integer
    result = 0

    if not isNullOrEmpty(duration)
        parts = duration.split(":")

        if parts.count() = 2
            result = StrToI(parts[0]) * 60
            result += StrToI(parts[1])
        end if
    end if

    return result
end function

function makeDivBy(input as Float, divisor as Integer) as Integer
    return cInt(input / divisor) * divisor
end function

function makeDivByThree(input as float) as integer
    return makeDivBy(input, 3)
end function

function generateNewUUID() as string
    return CreateObject("roDeviceInfo").GetRandomUUID()
end function

function parseErrors(errors as Object) as String
    msg = ""

    if isValid(errors)
        for each err in errors
            msg += substitute("{0}. ", getValue(err, "message", ""))
        end for
    end if

    return msg
end function

function getChannelVersion() as String
    appInfo = createObject("roAppInfo")
    return appInfo.getValueue("major_version") + "." + appInfo.getValueue("minor_version")
end function

function getChannelBuild() as String
    return createObject("roAppInfo").getValueue("build_version")
end function

function getChannelTitle() as String
    return createObject("roAppInfo").getTitle()
end function

function getChannelId() as String
    id = createObject("roAppInfo").getID()

    if id.Instr("_") >= 0
        id = id.split("_")[0]
    end if
    return id
end function

function sanitizeOddChars(input as string)
    r = CreateObject("roRegex", chr(699), "i")
    return r.ReplaceAll(input, chr(8216))
end function

function logTimeStamp()
    d = createObject("roDateTime")
    d.ToLocalTime()
    time = Substitute("{0}:{1}:{2}:{3}", d.getHours().toStr(), d.getMinutes().toStr(), d.getSeconds().toStr(), d.getMilliseconds().toStr())
    return time
end function

function calculatePercentage(value, total)
    if total <= 0 then return 0
    if value <= 0 then return 0

    return (value * 100) / total
end function

function getProgressBarWidth(percentage, totalWidth)
    return cInt(percentage * totalWidth / 100)
end function

function addQueryParamsToUrl(url as String, params as Object) as String
    keyValues = []
    for each key in params
        value = params[key]
        if value <> invalid
            keyValues.push(key + "=" + toString(value))
        end if
    end for

    if url.instr("?") < 0 then
        url += "?" + keyValues.join("&")
    else
        url += "&" + keyValues.join("&")
    end if
    return url
end function

sub startPerformanceTracking(name as String)
    #if debug
        m.performanceTrackingActiveName = name
        print "[PERFORMANCE] " name " - started"
        m.performanceTrackingTimeSpan = createObject("roTimespan")
    #end if
end sub

sub finishPerformanceTracking()
    #if debug
        if m.performanceTrackingTimeSpan = Invalid then
            print "tried to finish performance tracking but not started yet"
            return
        end if
        di = createObject("roDeviceInfo")
        versionParts = di.getOsVersion()
        version = substitute("{0}.{1}.{2}-{3}", versionParts.major, versionParts.minor, versionParts.revision, versionParts.build)
        print "[PERFORMANCE] " m.performanceTrackingActiveName " - finished" m.performanceTrackingTimeSpan.totalMilliseconds() "ms (" di.getModel() " " version ")"
        m.delete("performanceTrackingActiveName")
        m.delete("performanceTrackingTimeSpan")
    #end if
end sub

function generateMd5(stringInput as String) as String
    byteArray = createObject("roByteArray")
	byteArray.fromAsciiString(stringInput)
	digest = createObject("roEVPDigest")
	digest.setup("md5")
	return digest.process(byteArray)
end function

function isInViewportArea(node, resolution = { w: 1920, h: 1080})
    if isValid(node)
        rect = node.sceneBoundingRect()
        if (rect.width > 0 and rect.height > 0) and (rect.x >= 0 and rect.x <= resolution.w) and (rect.y >= 0 and (rect.y+rect.height) <= resolution.h) then return true
    end if
    return false
end function

sub findNodes(ids as Object)
    for each id in ids
        m[id] = m.top.findNode(id)
    end for
end sub

function getAllChildren(node as Object) as Object
    if node = invalid then return []
    return node.getChildren(-1, 0)
end function

function getAppRegistrySection() as Object
    registrySection = createObject("roRegistrySection", "AFAStream")
    return registrySection
end function

function getAppScene() as Object
    return m.top.getScene()
end function

function getMainScene() as Object
    return m.top.getScene().mainScene
end function

function hasInterface(x as dynamic, interfaceName as string) as boolean
    return getInterface(x, interfaceName) <> invalid
end function

function toString(x as dynamic) as dynamic
    if type(x) = "<uninitialized>" then return "uninitialized"
    if x = invalid then return "invalid"
    if hasInterface(x, "ifBoolean") then return iif(x, "true", "false")
    if hasInterface(x, "ifInt") then return stri(x).trim()
    if hasInterface(x, "ifFloat") or type(x) = "roFloat" then return str(x).trim()
    if hasInterface(x, "ifString") then return x
    if type(x) = "roAssociativeArray" then return formatJson(x)
    if hasInterface(x, "ifSGNodeDict") then return x.subType()
    return ""
end function

function createRequestNode(request, responseCallBack = "")
    requestNode = createObject("roSGNode", "Node")
    requestNode.update({request: request, response: {subType: "Node"}}, true)
    if responseCallBack <> "" then requestNode.observeFieldScoped("response", responseCallBack)

    return requestNode
end function

function convertMinutesIntToTimeFormat(time)
    result = ""

    if not time > 0 return ""
        
    minutes = int(time / 60)
    seconds = time - (minutes * 60)
    return iif(minutes < 10, "0" + minutes.toStr(), minutes.toStr()) + ":" + iif(seconds < 10, "0" + seconds.toStr(), seconds.toStr())
end function

function copyArrayWithNodes(items)
    result = []

    for each item in items
        if isNode(item)
            result.push(item.clone(true))
        end if
    end for
    
    return result
end function

sub onContentApiRequestResponseChanged(evt as Object)
    response = evt.getData()

    m.global.nr.callFunc("nrSendSystemEvent", "NETWORK_REQUEST_COMPLETE", {
        "requestId": response.requestId
        "url": response.url
        "parsingDuration": response.parsingDuration
        "totalDuration": response.totalDuration
    })
end sub

function convertDateTimeToMillisecondsUnixTimeStamp(dateTime as Object) as Double
    timestamp# = dateTime.asSeconds()
    timestamp# += dateTime.getSeconds() / 1000
    return timestamp#
end function

function secureText(text as String, char = "*") as String
    result = ""

    for i=0 to Len(text) -1
        result += char
    end for

    return result
end function

function getWatchListIcon()
    if m.isInWatchList = true
        return "pkg:/images/icon-check.png"
    else
        return "pkg:/images/icon-plus.png"
    end if
end function
'*************************************************************************
'#region *** Animation utils
'*************************************************************************
function isAnimationNode(node)
    return isValid(node) and node.subtype() = "Animation"
end function

sub startAnimation(node, isReverse = false)
    if not isAnimationNode(node) then return

    for each interpolator in node.getChildren(-1,0)
        interpolator.reverse = isReverse
    end for

    if node.state = "running" then node.control = "finish"

    node.control = "start"
end sub

sub completeAnimation(node)
    if not isAnimationNode(node) then return

    if node.state = "running"
        node.control = "finish"
    end if
end sub

function isAnimationRunning(node)
    if not isAnimationNode(node) then return false
    return node.state = "running"
end function

