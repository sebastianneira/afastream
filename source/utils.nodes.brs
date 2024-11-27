function focusChild(element as dynamic) as boolean
    if isValid(element)
        m.top.focusedElement = element
        return focusNode(element)
    end if

    return false
end function

function focusNext() as boolean
    if m.focusedIndex < m.top.getChildCount() - 1
        nextChild = findNextFocusable(m.focusedIndex)
        return focusChild(nextChild)
    end if

    return false
end function

function focusPrevious() as boolean
    if m.focusedIndex > 0
        prevChild = findPrevFocusable(m.focusedIndex)
        return focusChild(prevChild)
    end if

    return false
end function

function findNextFocusable(startIndex = 0 as integer) as dynamic
    for i = startIndex + 1 to m.top.getChildCount() - 1
        currentChild = m.top.getChild(i)
        if isValid(currentChild) and isFocusable(currentChild)
            if isFunction(setFocusedIndex) then
                setFocusedIndex(i) 'bs:disable-line 1001
            else
                print "setFocusedIndex not included in current scope"
            end if
            return currentChild
        end if
    end for

    return invalid
end function

function findPrevFocusable(startIndex = 0 as integer) as dynamic
    for i = startIndex - 1 to 0 step -1
        currentChild = m.top.getChild(i)
        if isValid(currentChild) and isFocusable(currentChild)
            if isFunction(setFocusedIndex) then
                setFocusedIndex(i) 'bs:disable-line 1001
            else
                print "setFocusedIndex not included in current scope"
            end if
            return currentChild
        end if
    end for

    return invalid
end function

function findNodeIndex(nodeId = "" as string) as integer
    for i = 0 to m.top.getChildCount() - 1
        currentChild = m.top.getChild(i)
        if isValid(currentChild) and isFocusable(currentChild) and currentChild.id = nodeId
            return i
        end if
    end for

    return -1
end function

function isFocusable(component as dynamic) as boolean
    result = component.focusable and component.visible
    skipFirstFocus = getValue(component, "skipFirstFocus", false)

    if skipFirstFocus
        component.skipFirstFocus = false
        result = false
    end if

    return result
end function

function focusNode(component as dynamic, setFocus = true as boolean) as boolean
    focused = false

    if isValid(component)' and isFocusable(component)
        component.setFocus(setFocus)
        focused = true
    end if

    return focused
end function

function getLastNodeIndex(node as object) as integer
    return node.getChildCount() - 1
end function

function removeAllNodeChildren(node as object) as boolean
    return node.removeChildrenIndex(node.getChildCount(), 0)
end function

function getChildByIndexOrLastNode(node, childIndex = 0)
    if childIndex > node.getChildCount() - 1
        childIndex = node.getChildCount() - 1
    end if

    return node.getChild(childIndex)
end function

function cloneNode(oldNode as object, includeChildren = true) as object
    removableFields = ["focusedChild", "change"]
    newNode = createObject("roSGNode", oldNode.subtype()) 'subtyped node should automatically have all the fields of the original node

    fields = oldNode.getFields()
    removeAssocArrayKeys(fields, removableFields)
    newNode.setFields(fields)

    if includeChildren
        for each item in oldNode.getChildren(-1, 0)
            child = newNode.createChild(item.subtype())
            childFields = item.getFields()
            removeAssocArrayKeys(childFields, removableFields)
            child.update(childFields, true)
        end for
    end if

    return newNode
end function