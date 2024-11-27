sub init()
    setComponents()
    setStyles()
    addObservers()
    initComponent()
end sub

sub setComponents()
    findNodes([
        "container"
        "title"
        "line"
        "accountInfo"
        "grpUser"
        "grpName"
        "name"
        "lastName"
        "grpContact"
        "email"
        "phone"
        "accountAccessTitle"
        "accountAccessLbl"
        "grpAddresss"
        "addressL1"
        "addressL2"
        "city"
        "state"
        "zip"
        "btnLogout"
        "accountCreated"
        "accountModified"
    ])
end sub

sub setStyles()
    vertSpacing = 21
    horizSpacing = 30
    m.grpUser.itemSpacings = [vertSpacing, vertSpacing, 12]
    m.grpName.itemSpacings = [horizSpacing]
    m.grpContact.itemSpacings = [horizSpacing]
    m.grpAddresss.itemSpacings = [vertSpacing]

    m.container.update({
        horizAlignment: "center"
        vertAlignment: "center"
        translation: [960, 540]
        itemSpacings: [21, 45, 66, 36, 9]
        opacity: 0
    })

    m.accountInfo.update({
        itemSpacings: [horizSpacing]
        focusable: false
    })

    m.title.update({
        text: tr("accountInformation")
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 45
        }
        maxLines: 1
        color: "0xCCCCCC"
        width: 1120
    })

    m.line.update({
        height: 1
        width: m.title.width
        color: "0x494949"
    })

    m.name.update({
        hint: tr("firstName")
        title: tr("firstName")
    })

    m.lastName.update({
        hint: tr("lastName")
        title: tr("lastName")
    })

    m.email.update({
        hint: tr("email")
        title: tr("email")
    })

    m.phone.update({
        hint: tr("phone")
        title: tr("phone")
    })

    m.accountAccessTitle.update({
        text: "Account type"
        horizAlign: "center"
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 18
        }
    })

    m.accountAccessLbl.update({
        text: ""
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 24
        }
        width: 630
        wrap: true
        maxLines: 3
    })

    m.addressL1.update({
        hint: tr("address")
        title: tr("addressL1")
        width: 450
    })

    m.addressL2.update({
        hint: tr("addressL2")
        title: tr("addressL2")
        width: 450
    })

    m.city.update({
        hint: tr("city")
        title: tr("city")
        width: 450
    })

    m.state.update({
        hint: tr("state")
        title: tr("state")
        width: 216
    })

    m.zip.update({
        hint: tr("zip")
        title: tr("zip")
        width: 216
    })

    m.btnLogout.update({
        text: tr("logout")
    })

    m.screenOpacityInterpolator.fieldToInterp = "container.opacity"
end sub

sub addObservers()
    m.btnLogout.observeField("selected", "onLogoutSelected")
end sub

sub initComponent()
    fillAccountInformation()
    startAnimation(m.screenAnimation)
end sub

sub onScreenInit()
end sub

sub fillTextField(nodeName, value)
    if m[nodeName] <> invalid
        m[nodeName].text = iif(value <> invalid, value, "")
    end if
end sub

sub fillAccountInformation()
    profile = m.global.userStateManager.user?.profile

    if profile <> invalid
        fillTextField("name", profile.firstName)
        fillTextField("lastName", profile.lastName)
        fillTextField("email", profile.email)
        fillTextField("phone", profile.phone)
        fillTextField("addressL1", profile.AddressLine1)
        fillTextField("addressL2", profile.AddressLine2)
        fillTextField("city", profile.city)
        fillTextField("state", profile.state)
        fillTextField("zip", profile.zipCode)

        if profile.isGCP
            m.accountAccessLbl.text = tr("gcp_account_info")
        else
            m.accountAccessLbl.text = tr("free_account_info")
        end if
    end if
end sub

sub onScreenFocusChanged(evt)
    if m.top.hasFocus()
        focusNode(m.btnLogout)
    end if
end sub

sub onLogoutSelected()
    registryDelete("user", "onUserDelete")
end sub

sub onUserDelete()
    m.global.user = CreateObject("roSGNode", "UserModel")
    clearStackAndNavigate("LandingScreen")
end sub