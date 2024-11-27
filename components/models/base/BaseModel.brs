sub init()
end sub

function adapt(entity)
    fields = m.top.getFields()

    for each field in fields
        if entity[field] <> invalid
            m.top[field] = entity[field]
        end if
    end for
end function

function returnAsAssocArray()
    result = {}

    fields = m.top.getFields()

    for each field in fields
        result[field] = m.top[field]
    end for

    return result
end function