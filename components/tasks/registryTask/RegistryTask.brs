sub init()
    m.registrySec = CreateObject("roRegistrySection", "AFAStream")
    m.port = createObject("roMessagePort")

    m.top.observeField("operation", m.port)
    m.top.observeFieldScoped("endTask", m.port)

    m.top.functionName = "initTask"
    m.top.control = "RUN"
end sub

sub initTask()
    while true
        message = wait(0, m.port)
        messageType = type(message)

        if messageType = "roSGNodeEvent" then
            field = message.getField()
            if field = "operation" then
                input = message.getData()[0]
                operation = input.request

                if operation.type = "read"
                    input.response = registryRead(operation)
                else if operation.type = "write"
                    input.response = registryWrite(operation)
                else if operation.type = "delete"
                    input.response = registryDeleteKey(operation)
                else if operation.type = "clean"
                    input.response = registryClean(operation)
                end if
            end if
        end if
    end while
end sub

function registryRead(operation as dynamic)
    result = CreateObject("roSGNode", "ContentNode")
    value = invalid
    callSuccess = true
    key = operation.key

    if m.registrySec.exists(key)
        value = m.registrySec.Read(key)
        if not isEmpty(value)
            value = ParseJSON(value)
        else
            callSuccess = false
        end if
    else
        callSuccess = false
    end if

    result.update({
        "key" : key
        "value" : value
        "type" : operation.type
        "wasSuccessful" : callSuccess
    }, true)

    return result
end function

function registryWrite(operation as dynamic)
    result = CreateObject("roSGNode", "ContentNode")
    callSuccess = m.registrySec.Write(operation.key,  FormatJSON(operation.value))

    result.update({
        "key" : operation.key
        "type" : operation.type
        "wasSuccessful" : callSuccess
    }, true)

    m.registrySec.flush()

    return result
end function

function registryDeleteKey(operation as dynamic)
    result = CreateObject("roSGNode", "ContentNode")
    callSuccess = true
    key = operation.key

    if m.registrySec.exists(key)
        m.registrySec.Delete(key)
    else
        callSuccess = false
    end if

    result.update({
        "key" : operation.key
        "type" : operation.type
        "wasSuccessful" : callSuccess
    }, true)

    return result
end function


function registryClean(operation as dynamic)
    result = CreateObject("roSGNode", "ContentNode")
    callSuccess = true
    keys = m.registrySec.GetKeyList()

    for each key in keys
        m.registrySec.Delete(key)
    end for

    result.update({
        "type" : operation.type
        "wasSuccessful" : callSuccess
    }, true)

    return result
end function
