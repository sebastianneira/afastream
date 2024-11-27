sub init()
    setComponents()
    setStyles()
    bindObservers()
    initComponent()

    addValidationLabel()
end sub

sub setComponents()
    findNodes([
        "input"
        "container"
        "box"
    ])
end sub

sub bindObservers()
    m.top.observeField("text", "onTextChanged")
    m.top.observeField("regex", "onRegexChanged")
    m.top.observeField("isSecureField", "onSecureTextChanged")
end sub

sub initComponent()
    m.isSecureField = false
    m.input.focusable = true
end sub

sub setStyles() 
    m.container.itemSpacings = [0]
    m.validationLabelStyle = {
        color: "0xFE5F55"
        maxLines: 1
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 18
        }
        wrap: false
        width: m.input.width
    }

    m.togglePasswordBtnStyle = {
        color: "0x3B3E46"
        focusColor: "0x2A2D33"
        selectedColor: "0x0D1A41"
        animate: false
    }
end sub

function validate() as Boolean
    validationSuccess = true

    if m.top.isMandatory
        minimumLength = iif(m.top.minimumLength < 1, 1, m.top.minimumLength)
        validationSuccess = Len(m.top.text) >= minimumLength
        
        if validationSuccess and isValid(m.regex)
            validationSuccess = validationSuccess and m.regex.isMatch(m.top.text)
        end if

        if validationSuccess
            removeValidationLabel()
        else
            addValidationLabel()
        end if
    end if

    m.top.isValid = validationSuccess
    return validationSuccess
end function

sub onTextChanged(evt)
    text = evt.getData()

    if m.top.isSecureField = true
        text = secureText(text)
    end if

    m.input.text = text
end sub

sub addValidationLabel()
    if not isValid(m.label)
        m.label = CreateObject("roSGNode", "Label")
        m.label.update(m.validationLabelStyle)    
        m.label.width = m.top.width

        m.container.appendChild(m.label)
    else
        m.label.text = m.top.validationMsg
    end if
end sub

sub removeValidationLabel()
    m.label.visible = false
end sub

sub onRegexChanged(evt)
    regex = evt.getData()

    if not isNullOrEmpty(regex)
        m.regex = CreateObject("roRegex", regex , "i")
    else
        m.regex = invalid
    end if
end sub

sub setBtnToggleStyle()
    xTranslation = m.input.width - m.toggleBtn.boundingRect().width + m.input.borderSize

    m.toggleBtn.update({
        height: m.top.height - m.input.borderSize * 2
        translation: [xTranslation, m.input.borderSize]
    })
end sub

sub onSecureTextChanged(evt)
    isSecure = evt.getData()

    if isSecure
        m.input.text = secureText(m.top.text)

        m.toggleBtn = m.box.createChild("Button")
        m.toggleBtn.text = ucase(tr("show"))
        m.toggleBtn.update(m.togglePasswordBtnStyle)

        m.toggleBtn.observeField("selected", "onToggleBtnSelected")
        m.top.observeField("height", "onHeightChanged")
        
        setBtnToggleStyle()
    else
        m.input.text = m.top.text
    end if
end sub

sub onToggleBtnSelected(evt)
    isSelected = evt.getData()

    if isSelected
        m.toggleBtn.text = ucase(tr("hide"))
        m.top.showPassword = true
        m.input.text = m.top.text
    else
        m.toggleBtn.text = ucase(tr("show"))
        m.top.showPassword = false
        m.input.text = secureText(m.top.text)
    end if

    setBtnToggleStyle()
end sub

sub onIsValidChanged(evt)
    isValidField = evt.getData()

    if not m.styleInitialized then return

    if isValidField
        m.inputBg.update(m.style.textBox.background)
    else
        m.inputBg.update(m.style.textBox.backgroundError)
    end if
end sub

sub onFocus()
    if m.top.hasFocus() then focusNode(m.input)
end sub

sub onHeightChanged(evt as dynamic)
    height = evt.getData()
    
    if isValid(m.toggleBtn) setBtnToggleStyle()
end sub

function onSelectableKeyPress(key as String, press as Boolean) as Boolean
    eventCaptured = false
   
    if not press then return eventCaptured
  
    if key = "right" and m.top.isSecureField
        focusNode(m.toggleBtn)
        eventCaptured = true
    else if key = "left" and m.top.isSecureField
        focusNode(m.input)
        eventCaptured = true
    end if

    return eventCaptured
end function