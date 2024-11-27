function createRegistryOperation(key, operationType, value, callback = "")
    operationNode = createObject("roSGNode", "Node")
    operationNode.update({
        request: { key: key, type: operationType, value: value },
        response: {
            subType: "Node"
        },
    }, true)

    if not isNullOrEmpty(callback) then operationNode.observeFieldScoped("response", callback)
    
    return operationNode
end function

function registryRead(key, callback = "") as dynamic
    m.global.registryTask.operation = [createRegistryOperation(key, "read", {}, callback)]
end function

function registryWrite(key, value, callback = "") as dynamic
    m.global.registryTask.operation = [createRegistryOperation(key, "write", value, callback)]
end function

function registryDelete(key, callback = "") as dynamic
    m.global.registryTask.operation = [createRegistryOperation(key, "delete", {}, callback)]
end function

function registryClean(key, callback = "") as dynamic
    m.global.registryTask.operation = [createRegistryOperation(key, "clean", {}, callback)]
end function