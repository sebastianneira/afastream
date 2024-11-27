sub init()
    setComponents()
    setStyle()
end sub

sub setComponents()
    findNodes([
        "metaLineOne"
        "metaLineTwo"
        "metaLineThree"
        "container"
    ])

end sub

sub setStyle()
    m.labelStyle = {
        font: {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 18
        }
    }

    m.container.update({
        width: 210
        height: 99
        color: "0x333333"
    })

    m.metaLineOne.update(m.labelStyle)

    m.metaLineTwo.update(m.labelStyle)
    m.metaLineTwo.translation = [0, 33]

    m.metaLineThree.update(m.labelStyle)
    m.metaLineThree.translation = [0, 66]
end sub
