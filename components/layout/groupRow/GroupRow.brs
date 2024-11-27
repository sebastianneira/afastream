sub init()
    m.keyAction = {
        "down" : focusNext
        "up": focusPrevious
    }

    m.totalY = 0
    m.top.observeField("stackChildren", "onStackChildrenChanged")
end sub

sub onStackChildrenChanged(evt as Dynamic)
    stack = evt.getData()

    if stack
        m.top.observeField("change", "onNodeChanged")
    end if
end sub

sub onNodeChanged(evt as Dynamic)
    changeEvt = evt.getData()

    if isValid(changeEvt)
        if changeEvt.operation = "add"
            child = m.top.getChild(changeEvt.index1)
            child.translation = [0, m.totalY]

            if child.hasField("height")
                m.totalY += child.getField("height")
            end if
        end if
    end if
end sub