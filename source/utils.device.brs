function getChannelClientId() as String
    return createObject("roDeviceInfo").getChannelClientId()
end function

function getDeviceModel() as String
    return createObject("roDeviceInfo").getModel()
end function

function getDeviceTimeZone() as String
    return createObject("roDeviceInfo").getTimeZone()
end function

function getDeviceDisplayNameAndModel() as String
    di = createObject("roDeviceInfo")
    return di.getModelDisplayName() + " " + di.getModel()
end function

function getDeviceOsVersion() as String
    osVersion = createObject("roDeviceInfo").getOSVersion()
    return substitute("{0}.{1}.{2}-{3}", osVersion.major, osVersion.minor, osVersion.revision, osVersion.build)
end function

function getTimeSinceLastKeypress() as Integer
    return createObject("roDeviceInfo").timeSinceLastKeypress()
end function

function getDeviceConnectionInfo() as Object
    return createObject("roDeviceInfo").getConnectionInfo()
end function

function getDeviceUIResolution() as Object
    return createObject("roDeviceInfo").getUIResolution()
end function

function getDeviceCurrentLocale() as String
    return createObject("roDeviceInfo").getCurrentLocale().replace("_", "-")
end function

function isDeviceRIDADisabled() as Boolean
    return createObject("roDeviceInfo").isRIDADisabled()
end function

function getDeviceCountryCode() as String
    return createObject("roDeviceInfo").getCountryCode()
end function

function isOpenGLDevice() as Boolean
    return createObject("roDeviceInfo").getGraphicsPlatform() = "opengl"
end function


function getDeviceSoundEffectsVolume() as Integer
    return createObject("roDeviceInfo").getSoundEffectsVolume()
end function

function getDeviceStatus() as string
    status = "current"

    legacy = [
        "N1000"
        "N1050"
        "N1100"
        "N1101"
        "2000C"
        "2050X"
        "2050N"
        "2100X"
        "2100N"
        "2400X"
        "3000X"
        "3050X"
        "3100X"
        "2450X"
        "2500X"
        "3400X"
        "3420X"
    ]

    updatable = [
        "3600X"
        "3700X"
        "3710X"
        "3800X"
        "3900X"
        "3910X"
        "4620X"
        "4630X"
        "4640X"
        "4660X"
        "4670X"
        "4200X"
        "2700X"
        "2710X"
        "2720X"
        "3500X"
        "4210X"
        "4230X"
        "4400X"
        "5000X"
        "6000X"
    ]

    model = getDeviceModel()
    for each device in legacy
        if device = model
            return "legacy"
        end if
    end for

    for each device in updatable
        if device = model
            return "updatable"
        end if
    end for

    return status
end function
