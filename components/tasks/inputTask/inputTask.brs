sub Init()
    m.port = createObject("roMessagePort")
    m.transportIdList = {}

    m.top.observeField("transportResponse", m.port)
    m.top.observeFieldScoped("endTask", m.port)

    m.top.functionName = "listenInput"
    m.top.control = "RUN"
end sub

sub listenInput()
    inputObject = createObject("roInput")
    inputObject.setMessagePort(m.port)

    inputObject.enableTransportEvents()

    while true
        msg = wait(0, m.port)
        messageType = type(msg)
        if messageType = "roInputEvent" then
            if msg.isInput()
                inputData = msg.getInfo()

                ' We don't handle RALE messages so exit out early
                if inputData.rale <> Invalid then return

                for each item in inputData
                    print item + ": " inputData[item]
                end for

                ' pass the deeplink to UI
                if inputData.DoesExist("mediaType") and inputData.DoesExist("contentID")
                    deeplink = {
                        id: inputData.contentID
                        mediaType: inputData.mediaType
                        type: "deeplink"
                    }

                    print "got input deeplink= "; deeplink
                    m.top.inputData = deeplink
                else if inputData.DoesExist("type") and inputData.type = "transport"
                    transport = {
                        id: inputData.id
                        command: inputData.command
                        duration: inputData.duration
                        direction: inputData.direction
                        type: inputData.type
                    }

                    print "got transport input= "; transport
                    m.transportIdList[inputData.id] = { transport: transport }
                    ? "id list size= "; m.transportIdList.count()
                    m.top.inputData = transport
                end if
            end if
        else if messageType = "roSGNodeEvent" then
            field = msg.getField()
            if field = "transportResponse"
                response = msg.getData()
                ? "transport response= "; response
                id = response.id
                job = m.transportIdList[id]
                if job <> invalid
                    eventStatus = response.status
                    ' Send the response (may need to be after command executed)
                    inputObject.EventResponse({ id: inputData.id, status: eventStatus })
                    m.transportIdList.delete(id)
                    ? "deleted from list id= "; id
                else
                    ? "id= "; id; " not found"
                end if
            else if field = "endTask" then
                return
            end if
        end if
    end while
end sub
