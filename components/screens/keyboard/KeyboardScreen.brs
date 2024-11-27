sub init()
    ' setComponents()
    ' addObservers()
    ' setStyles()
    ' initComponent()
end sub


' sub setComponents()
'     m.background = m.top.findNode("keyboardBg")
'     m.keyboardRow = m.top.findNode("keyboardRow")
'     m.btnsRow = m.top.findNode("btnsRow")
'     m.keyBoard = m.top.findNode("keyboard")
'     m.btnOK = m.top.findNode("btnOK")
'     m.btnCancel = m.top.findNode("btnCancel")
'     m.btnSecureMode = m.top.findNode("btnSecureMode")
'     m.spacerBtnScureMode = m.top.findNode("spacerBtnScureMode")
'     m.grpSecureBtn = m.top.findNode("grpSecureBtn")
'     m.rowSecureBtn = m.top.findNode("rowSecureBtn")
' end sub

' sub addObservers()
'     m.btnOK.observeField("selected", "onConfirm")
'     m.btnCancel.observeField("selected", "onCancel")
'     m.btnSecureMode.observeField("selected", "onToggleSecureMode")
' end sub

' sub setStyles()
'     applyStyle(m.btnOK, "btnRed300x81")
'     applyStyle(m.btnCancel, "btnGrey300x81")
' end sub

' sub initComponent()
'     m.btnOK.text = ucase(localize("OK"))
'     m.btnCancel.text = localize("CANCEL")
'     m.btnSecureMode.text = localize("SHOW_PASSWORD")
' end sub

' sub onModelChanged(evt as Dynamic)
'     m.key = getValue(m.top.model, "key", "")
'     m.top.title = getValue(m.top.model, "title", "")
'     isSecure = getValue(m.top.model, "isSecure", false)

'     m.keyboard.text = getValue(m.top.model, "text", "")
'     m.keyBoard.textEditBox.secureMode = isSecure

'     if not isSecure
'         m.keyboardRow.removeChild(m.btnSecureMode)
'         'resetting focus
'         m.keyboardRow.resetIndex = true
'         m.keyboardRow.forceFocus = "keyboard"
'         m.background.height = 699
'     end if
' end sub

' sub onConfirm()
'     closeModal({ option: "confirm", key: m.key, text: m.keyboard.text})
' end sub

' sub onCancel()
'     closeModal({ option: "canceled"})
' end sub

' sub onToggleSecureMode()
'     m.keyBoard.textEditBox.secureMode = not m.keyBoard.textEditBox.secureMode

'     if m.keyBoard.textEditBox.secureMode
'         m.btnSecureMode.text = localize("SHOW_PASSWORD")
'     else
'         m.btnSecureMode.text = localize("HIDE_PASSWORD")
'     end if
' end sub

function onKeyEvent(key,press) as Boolean
    if press 
        if key = "back"
            navigateBack()
            return true
        end if
    end if

    return false
end function