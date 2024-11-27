sub init()
    homeTileLarge_setComponents()
    homeTileLarge_setStyles()
end sub

sub homeTileLarge_setComponents()
    findNodes([
        "meta"
        "metaLineOne"
        "metaLineTwo"
        "metaLineThree"
    ])

end sub

sub homeTileLarge_setStyles()
    m.fontRegular = {
        "subType": "font",
        "role": "font",
        "uri": "pkg:/locale/font/Roboto-Regular.ttf",
        "size": 18
    }

    m.fontBold = {
        "subType": "font",
        "role": "font",
        "uri": "pkg:/locale/font/Roboto-Bold.ttf",
        "size": 18
    }

    m.labelStyle = {
        width: m.image.width - 12
        font: m.fontRegular
    }

    m.meta.update({
        width: m.image.width
        height: 120
        color: "0x333333"
        translation: [0, m.imageHeight]
    })

    m.metaLineOne.update(m.labelStyle)
    m.metaLineOne.update({
        wrap: true
        maxLines: 2
        lineSpacing: 6
        translation: [6, 9]
    })

    m.metaLineTwo.update(m.labelStyle)
    m.metaLineTwo.translation = [6, 60]

    m.metaLineThree.update(m.labelStyle)
    m.metaLineThree.translation = [6, 90]
end sub

sub setupHomeTileLarge(evt)
    content = evt.getData()

    'Template
    runTime = 0
    timeLeft = 0
    timeStamp = content?.session?.timeStamp
    timeStamp = iif(timeStamp <> invalid, timeStamp, 0)

    if content.isSeries = true and content.episode <> invalid
        runTime = content.episode.runTimeSeconds
    else
        runTime = content.runTimeSeconds
    end if

    timeLeft = cInt((runtime - timeStamp) / 60)

    if content.template = "continue_watching"
        m.metaLineOne.text = content.title
        m.metaLineTwo.text = ""

        m.metaLineOne.update({font: m.fontRegular})

    else if content.template = "new_episodes"
        m.metaLineOne.text = iif(content?.episode?.title <> invalid, content?.episode?.title, "")
        m.metaLineTwo.text = content.title
        
        m.metaLineOne.update({font: m.fontBold})
    end if

    m.metaLineThree.text = Substitute(tr("time_left_menutes"), timeLeft.toStr())
end sub

sub itemContentChanged(evt)
    if isValid(setupHomeTile)
        setupHomeTile(evt)
    end if

    setupHomeTileLarge(evt)
end sub