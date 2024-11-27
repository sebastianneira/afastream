sub main(args as dynamic)
    timeSinceApplicationStart = createObject("roAppManager").getUptime().totalMilliseconds()
    applicationStartTime = convertDateTimeToMillisecondsUnixTimeStamp(createObject("roDateTime"))
    applicationStartTime -= timeSinceApplicationStart / 1000
    waitTime = 0
    defaultWaitTime = 0
    connectionLostWaitTime = 10000
    isNetworkConnected = true
    deviceInfo = createObject("roDeviceInfo")
    screen = CreateObject("roSGScreen")
    scene = screen.createScene("MainScene")
    m.port = CreateObject("roMessagePort")
    m.keepRuning = true
    deeplink = invalid
    if args.contentid <> invalid and args.mediaType <> invalid
        deeplink = {
            id: args.contentId
            type: args.mediaType
        }
    end if

    m.global = screen.getGlobalNode()
    m.global.update({
        "config": getConfig()
        "deeplink": deeplink
        "applicationStartTime": applicationStartTime
    }, true)

    deviceInfo.setMessagePort(m.port)
    deviceInfo.enableLowGeneralMemoryEvent(true)
    deviceInfo.enableLinkStatusEvent(true)

    screen.setMessagePort(m.port)
    screen.show() ' vscode_rale_tracker_entry
    
    activeLogs = false
    #if logging
        activeLogs = true
    #end if

    while(m.keepRuning)
        msg = wait(waitTime, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed()
                exit while
            end if
        else if msgType = "roDeviceInfoEvent"
            info = msg.getInfo()

            if info.linkStatus <> invalid
                if info.linkStatus = true
                    waitTime = defaultWaitTime
                    isNetworkConnected = true
                else
                    waitTime = connectionLostWaitTime
                    isNetworkConnected = false
                end if
            end if
        else if not isNetworkConnected
            waitTime = defaultWaitTime
            m.global.setField("isNetworkConnected", false)
        end if
    end while
end sub