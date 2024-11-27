'*************************************************************************
'#region *** Screen setup
'*************************************************************************

sub init()
    setComponents()
    addObservers()
    setStyles()
    initComponent()
end sub

sub setComponents()
    findNodes([
        "background"
        "overlay"
        "content"
        "title"
        "subTitle"
        "thirdTitle"
        "badge"
        "summary"
        "buttons"
        "btnPlay"
        "btnWatchList"
        "panel"
        "panelBackground"
        "panelContent"
        "panelEpisodes"
        "episodesTitle"
        "episodesPages"
        "episodes"
        "panelContentLeft"
        "panelContentRight"
        "producersGroup"
        "castGroup"
        "releaseYearGroup"
        "copyrightGroup"
        "moreInfoTitle"
        "moreInformation"
        "producersTitle"
        "producers"
        "castTitle"
        "cast"
        "releaseYearTitle"
        "releaseYear"
        "copyrightTitle"
        "copyright"
        "panelAnimation"
        "panelBgOpacityInterpolator"
        "panelContentOpacityInterpolator"
        "panelTranslationInterpolator"
        "panelContentInterpolator"
        "upgradeAccountBadge"
        "upgAccBackground"
        "upgAccMessage"
    ])
end sub

sub addObservers()
    m.btnPlay.observeField("selected", "onBtnPlaySelected")
    m.btnWatchList.observeField("selected", "onBtnWatchlistSelected")
    m.background.observeField("loadStatus", "onBgloadStatusChanged")
end sub

sub setStyles()
    m.playLockedStyle = {
        color: "0x333333"
        focusColor: "0x5A5959"
        text: UCase(tr("play"))
        icon: "pkg:/images/icon-lock.png"
    }

    panelTitleStyle = {
        "color": "0xFFFFFF"
        "wrap": false
        "font": {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 36
        }
    }

    panelLabelStyle = {
        "width": 600
        "color": "0xFFFFFF"
        "wrap": true
        "maxLines": 2
        "font": {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 24
        }
    }

    m.background.update({
        opacity: 0
        width: 1920
        height: 1080
        loadWidth: 1920
        loadHeight: 1080
        loadDisplayMode: "scaleToZoom"
    })

    m.overlay.update({
        width: 1920
        height: 1080
        uri: "pkg:/images/background_overlay.png"
    })

    'Detail
    m.content.update({
        translation: [120, 225]
        itemSpacings: [18, 21, 15, 42, 51]
    })

    m.title.update({
        "color": "0xFFFFFF"
        "maxLines": 1
        "font": {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 72
        }
    })

    m.subTitle.update({
        "color": "0xFFFFFF"
        "maxLines": 1
        "font": {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 36
        }
    })

    m.thirdTitle.update({
        "color": "0xFFFFFF"
        "maxLines": 1
        "font": {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 27
        }
    })

    m.summary.update({
        "color": "0xFFFFFF"
        "width": 990
        "wrap": true
        "maxLines": 7
        "font": {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 24
        }
    })

    m.btnPlay.icon = "pkg:/images/icon-play.png"
    m.btnWatchList.text = ucase(tr("watch_list"))

    'Panel
    m.panel.update({
        translation: [0, 900]
        visible: false
        opacity: 0.5
    })

    m.panelBackground.update({
        width: 1920
        height: 1080
        opacity: 0
        color: "0x000000"
    })

    m.panelContent.update({
        visible: false
        translation: [120, 30]
        itemSpacings: [150]
        layoutDirection: "horiz"
    })

    m.panelContentLeft.update({
        visible: false
        itemSpacings: [30]
    })
    m.panelContentRight.itemSpacings = [30]
    m.panelEpisodes.visible = false

    for each layoutGroup in getAllChildren(m.panelContentRight)
        layoutGroup.itemSpacings = [12]
    end for

    m.episodesTitle.update(panelTitleStyle)
    m.episodesTitle.update({
        text: tr("episodes")
        translation: [105, 30]
    })

    m.episodes.update({
        scollOnEveryItem: false
        translation: [105, 99]
        clippingRect: [0, 0, 1920, 810]
    })

    m.episodesPages.update({
        itemSpacings: [6]
        horizAlignment: "center"
        translation: [960, 960]
    })

    m.moreInfoTitle.update(panelTitleStyle)
    m.moreInfoTitle.text = tr("more_information")

    m.producersTitle.update(panelTitleStyle)
    m.producersTitle.text = tr("producers")

    m.castTitle.update(panelTitleStyle)
    m.castTitle.text = tr("cast_crew")

    m.releaseYearTitle.update(panelTitleStyle)
    m.releaseYearTitle.text = tr("release_year")

    m.copyrightTitle.update(panelTitleStyle)
    m.copyrightTitle.text = tr("copyright_date")

    m.moreInformation.update({
        "width": 750
        "color": "0xFFFFFF"
        "wrap": true
        "font": {
            "subType": "font",
            "role": "font",
            "uri": "pkg:/locale/font/Roboto-Regular.ttf",
            "size": 24
        }
    })

    m.producers.update(panelLabelStyle)
    m.cast.update(panelLabelStyle)
    m.releaseYear.update(panelLabelStyle)
    m.copyright.update(panelLabelStyle)

    'Animation
    m.screenOpacityInterpolator.fieldToInterp = "background.opacity"

    m.panelAnimation.update({
        duration: 0.4,
        optional: true
    })

    m.panelBgOpacityInterpolator.update({
        key: [0.0, 1.0],
        keyValue: [m.panelBackground.opacity, 0.9]
        fieldToInterp: "panelBackground.opacity"
    })
    m.panelContentOpacityInterpolator.update({
        key: [0.0, 1.0],
        keyValue: [m.panel.opacity, 1],
        fieldToInterp: "panel.opacity"
    })
    m.panelTranslationInterpolator.update({
        key: [0.0, 1.0],
        keyValue: [m.panel.translation, [m.panel.translation[0], 0]]
        fieldToInterp: "panel.translation"
    })
    m.panelContentInterpolator.update({
        key: [0.0, 1.0],
        keyValue: [m.panelContent.translation, [m.panelContent.translation[0], m.panelContent.translation[0]]]
        fieldToInterp: "panelContent.translation"
    })

    m.upgAccMessageStyle = {
        text: tr("account_upgrade_badge")
        color: "0xFFFFFF"
        wrap: false
        font: {
            subType: "font",
            role: "font",
            uri: "pkg:/locale/font/Roboto-Regular.ttf",
            size: 24
        }
        translation: [21, 6]
    }

    'upgrade account msg
    m.upgAccBackgroundStyle = {
        blendColor: "0x000000"
        opacity: 0.6
        uri: "pkg:/images/33px-round-fhd.9.png"
    }

    'buttons
    m.buttons.itemSpacings = [33]
end sub

sub initComponent()
    m.isDeepLink = false
    m.panelVisible = false
    m.pageSize = 25
end sub

'*************************************************************************
'#region *** Screen events
'*************************************************************************

sub onScreenFocusChanged(evt)
end sub

sub onSreenInit()
end sub

sub onScreenRevisit()
    focusNode(m.buttons)

    if m.panelVisible
        focusNode(m.episodes)
    else
        progress = m.global.userStateManager.callFunc("getVideoSessionProgress", { videoId: m.btnPlayModel.videoId, episodeId: m.btnPlayModel.episodeId })

        if progress <> invalid
            playTxt = ucase(tr("play"))

            if m.btnPlay.text.instr(playTxt) >= 0
                resumeTxt = ucase(tr("resume"))
                m.btnPlay.text = m.btnPlay.text.replace(playTxt, resumeTxt)
            end if
            m.btnPlay.progressPercent = calculatePercentage(progress, m.btnPlayModel.RuntimeSeconds)

            createRestartButton()
        end if
    end if
end sub

sub onScreenNavBack(context)
    if context <> invalid
        for each episodeItem in m.episodes.findNode("container")?.getChildren(-1, 0)
            if episodeItem.episode.id = context.episodeId
                episodeItem.timeStamp = context.timeStamp
                exit for
            end if
        end for
    end if
end sub

function showScreen()
    isScreenLoading(false)
    startAnimation(m.screenAnimation)
    focusNode(m.buttons)

    m.panel.visible = true
end function

'*************************************************************************
'#region *** Screen logic
'*************************************************************************

sub getSeriesEpisodes()
    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        path: "video/episodes"
        method: "POST"
        parser: "episodesPage"
        body: {
            videoId: m.top.model.videoId,
            take: 99
            page: 1
        }
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.request = requestContext.callFunc("getRequest")
    requestNode.observeFieldScoped("response", "onGetSeriesEpisodes")
    m.httpTask.requests = [requestNode]
end sub

'*************************************************************************
'#region *** Model setup
'*************************************************************************

sub onModelChanged(evt as dynamic)
    model = evt.getData()

    if isValid(model)
        m.isDeepLink = model.isDeepLink
        m.instantPlay = model.instantPlay = true
        isScreenLoading(true)
        loadFullVideoDetail(model.videoId)
    else
        'invalid model
        navigateBack()
    end if
end sub

function loadFullVideoDetail(id)
    requestContext = CreateObject("roSGNode", "RequestContext")
    requestContext.update({
        path: "video/videodetails/" + id.toStr()
        method: "GET"
    })

    requestNode = createObject("roSGNode", "RequestNode")
    requestNode.request = requestContext.callFunc("getRequest")
    requestNode.observeFieldScoped("response", "onGetVideoFullDetail")
    m.httpTask.requests = [requestNode]
end function

'*************************************************************************
'#region *** Screen callbacks
'*************************************************************************

sub onGetVideoFullDetail(evt)
    result = evt.getData()
    ?result
    'If model is not valid return to previous screen
    if not result.wasSuccessful or result.content?.video = invalid
        navigateBack()
        return
    end if

    model = result.content?.video
    session = result.content?.session
    watchListItems = m.global.userStateManager.callFunc("getWatchList")
    m.isEntitledToPlay = not (model.isGCP = true and m.global.userStateManager.user?.profile?.isGCP = false)
    m.isInWatchList = watchListItems[model?.id.toStr()] <> invalid
    m.btnPlayModel = CreateObject("roSGNode", "VideoPlayerModel")
    m.videoId = model?.id
    m.isLive = m.global.liveStreamsManager?.liveStreamShow?.videoId = m.videoId

    'Background
    backgroundUri = ""

    if m.top.model?.wideImageUrl <> invalid
        backgroundUri = m.top.model?.WideImageUrl
    else if m.top.model?.backgroundImage <> invalid
        backgroundUri = m.top.model?.backgroundImage
    else if model.isSeries = true
        backgroundUri = result.content?.episodes?[0]?.episode?.image
    else if model.rotatorImages?[0].url <> invalid
        backgroundUri = model.rotatorImages?[0].url
    end if

    m.background.uri = m.global.environmentUrl + backgroundUri

    'Set detail info
    m.title.text = model.title
    m.subTitle.text = model.subTitle
    m.summary.text = iif(isValid(model.summary), model.summary, "")

    if model.isGCP = true
        m.badge.callFunc("setToGCPBadge")
    else
        m.badge.callFunc("setToFreeBadge")
    end if

    'watchlist
    m.btnWatchList.icon = getWatchListIcon()
    'm.btnWatchList.text = ucase(tr("watch_list"))

    if model.isSeries = true
        getSeriesEpisodes()

        if m.isEntitledToPlay
            if isValid(session)
                sessionEpisode = session?.episode

                m.btnPlayModel.update({
                    videoId: model.id
                    episodeId: sessionEpisode.id
                    title: sessionEpisode.title
                    cloudflareVideoId: sessionEpisode.cloudflareVideoId
                    airDateFormatted: sessionEpisode.airDateFormatted
                    timeStamp: iif(session.timeStamp = invalid, 0, session.timeStamp)
                    episodeIndex: iif(session.episodeIndex = invalid, 0, session.episodeIndex)
                    runTimeSeconds: sessionEpisode.RuntimeSeconds
                    isGCP: sessionEpisode.isGCP
                    parentalGuidance: sessionEpisode.parentalGuidance
                })

                if session.lastWatched <> invalid
                    m.btnPlay.text = UCase(tr("resume") + " " + sessionEpisode.title)
                    m.btnPlay.progressPercent = calculatePercentage(session.timeStamp, sessionEpisode.RuntimeSeconds)
                    createRestartButton()
                else
                    m.btnPlay.text = UCase(tr("play") + " " + sessionEpisode.title)
                end if
            else if result.content?.Episodes?[0] <> invalid
                firstEpisode = result.content.Episodes[0]

                m.btnPlayModel.update({
                    videoId: model.id
                    episodeId: firstEpisode.id
                    title: firstEpisode.title
                    cloudflareVideoId: firstEpisode.cloudflareVideoId
                    airDateFormatted: firstEpisode.airDateFormatted
                    runTimeSeconds: firstEpisode.runtimeSeconds
                    isGCP: firstEpisode.isGCP
                    parentalGuidance: firstEpisode.parentalGuidance
                })

                m.btnPlay.text = UCase(tr("play") + " " + firstEpisode.title)
            end if
        end if

        m.panelEpisodes.visible = true
    else
        details = model.details

        if details <> invalid
            m.thirdTitle.text = tr("runtime") + ": " + details.runtime

            m.panelContent.visible = true

            if isNonEmptyString(details.MoreInformation)
                m.moreInformation.text = details.MoreInformation
                m.panelContentLeft.visible = true
            end if

            if isNonEmptyString(details.Producers)
                m.producers.text = details.Producers
            else
                m.panelContentRight.removeChild(m.producersGroup)
            end if

            if isNonEmptyString(details.CastAndCrew)
                m.cast.text = details.CastAndCrew
            else
                m.panelContentRight.removeChild(m.castGroup)
            end if

            if isNonEmptyString(details.ReleaseYear)
                m.releaseYear.text = details.ReleaseYear
            else
                m.panelContentRight.removeChild(m.releaseYearGroup)
            end if

            if isNonEmptyString(details.copyrightDate)
                m.copyright.text = details.copyrightDate
            else
                m.panelContentRight.removeChild(m.copyrightGroup)
            end if
        end if

        if m.isEntitledToPlay
            m.btnPlayModel.update({
                videoId: model.id
                title: model.title
                cloudflareVideoId: model.cloudflareVideoId
                runTimeSeconds: iif(details.runtimeSeconds <> invalid, details.runtimeSeconds, 0)
                parentalGuidance: model.parentalGuidance
            })

            if isValid(session)
                m.btnPlayModel.timeStamp = iif(session.timeStamp = invalid, 0, session.timeStamp)
                m.btnPlay.text = UCase(tr("resume"))
                m.btnPlay.progressPercent = calculatePercentage(session.timeStamp, m.btnPlayModel.RuntimeSeconds)

                createRestartButton()
            else
                m.btnPlay.text = UCase(tr("play"))
            end if
        end if

        if model.CloudflareTrailerId <> invalid
            m.btnTrailerModel = CreateObject("roSGNode", "VideoPlayerModel")
            m.btnTrailerModel.update({
                videoId: model.id
                title: model.title
                cloudflareVideoId: model.CloudflareTrailerId
                isTrailer: true
            })

            createTrailerButton()
        end if
    end if

    if m.isLive and m.isEntitledToPlay
        m.buttons.removeChild(m.btnPlay)
        createWatchLiveButton()
    end if

    if not m.isEntitledToPlay
        m.btnPlay.update(m.playLockedStyle)
        m.btnPlay.unObserveField("selected")
        createAccountUpgradeMessage()
    end if

    if m.instantPlay and m.isEntitledToPlay
        if m.isLive
            onBtnWatchNowSelected()
        else
            onBtnPlaySelected()
        end if
    end if

    m.modelReady = true

    if m.background.loadStatus = "ready" or m.background.loadStatus = "failed"
        showScreen()
    end if
end sub

sub onGetSeriesEpisodes(evt)
    result = evt.getData()

    if result.wasSuccessful
        scrollerContainer = m.episodes.findNode("container")
        episodes = result.content.items

        if isArray(episodes) and episodes.count() > 0
            for each episode in episodes
                item = scrollerContainer.createChild("EpisodeItem")
                item.update({
                    episode: episode.episode
                    timeStamp: episode?.session?.timestamp
                    isEntitledToPlay: m.isEntitledToPlay
                })

                if m.isEntitledToPlay
                    item.observeField("selected", "onEpisodeItemSelected")
                end if
            end for
        end if
    end if
end sub

sub onBtnWatchNowSelected()
    liveStreamShow = m.global.liveStreamsManager?.liveStreamShow

    if liveStreamShow <> invalid
        livePlayerModel = CreateObject("roSGNode", "VideoPlayerModel")
        livePlayerModel.update({
            title: liveStreamShow.heading
            isLive: true
            liveUrl: liveStreamShow.liveUrl
        })

        navigate("VideoPlayerScreen", livePlayerModel)
    end if
end sub

sub onBtnPlaySelected()
    navigate("VideoPlayerScreen", m.btnPlayModel)
end sub

sub onBtnTrailerSelected()
    navigate("VideoPlayerScreen", m.btnTrailerModel)
end sub

sub onBtnRestartSelected()
    m.btnPlayModel.restartProgess = true
    navigate("VideoPlayerScreen", m.btnPlayModel)
end sub

sub onBtnWatchlistSelected()
    if m.isInWatchList
        m.global.userStateManager.callFunc("removeFromWatchList", m.videoId)
    else
        m.global.userStateManager.callFunc("addToWatchList", m.videoId)
    end if

    m.isInWatchList = not m.isInWatchList
    m.btnWatchList.icon = getWatchListIcon()
end sub

sub onBgloadStatusChanged(evt)
    status = evt.getData()

    if m.modelReady = true and (status = "ready" or status = "failed")
        showScreen()
    end if
end sub

sub onEpisodeItemSelected(evt)
    item = evt.getRoSGNode()

    if item <> invalid and item.episode <> invalid
        playModel = CreateObject("roSGNode", "VideoPlayerModel")
        playModel.update({
            videoId: m.videoId
            episodeId: item.episode.id
            title: item.episode.title
            cloudflareVideoId: item.episode.cloudflareVideoId
            airDateFormatted: item.episode.airDateFormatted
            timeStamp: iif(item?.session?.timeStamp = invalid, 0, item?.session?.timeStamp)
            episodeIndex: iif(item?.session?.episodeIndex = invalid, 0, item?.session?.episodeIndex)
            isGCP: item.episode.isGCP
            parentalGuidance: item.episode.parentalGuidance
        })
        navigate("VideoPlayerScreen", playModel)
    end if
end sub

'*************************************************************************
'#region *** Screen utils
'*************************************************************************

sub createWatchLiveButton()
    m.btnWatchLive = CreateObject("roSGNode", "Button")
    m.btnWatchLive.text = ucase(tr("watch_live"))

    m.btnWatchLive.observeField("selected", "onBtnWatchNowSelected")

    m.buttons.insertChild(m.btnWatchLive, 0)
end sub

sub createTrailerButton()
    m.btnTrailer = CreateObject("roSGNode", "Button")
    m.btnTrailer.text = ucase(tr("trailer"))

    m.btnTrailer.observeField("selected", "onBtnTrailerSelected")

    m.buttons.insertChild(m.btnTrailer, 1)
end sub

sub createRestartButton()
    if m.btnRestart <> invalid then return

    m.btnRestart = CreateObject("roSGNode", "Button")
    m.btnRestart.text = ucase(tr("restart"))

    m.btnRestart.observeField("selected", "onBtnRestartSelected")

    m.buttons.insertChild(m.btnRestart, m.buttons.getChildCount() - 1)
end sub

sub createAccountUpgradeMessage()
    m.upgradeAccountBadge = CreateObject("roSGNode", "Group")
    m.upgradeAccountBackground = m.upgradeAccountBadge.createChild("Poster")
    m.upgradeAccountLabel = m.upgradeAccountBadge.createChild("Label")
    m.accountBadgeAnimation = m.top.createChild("Animation")
    m.badgeBackgroundInterpolator = m.accountBadgeAnimation.createChild("FloatFieldInterpolator")

    m.upgradeAccountBadge.update({
        id: "accountUpgradeBadge"
        opacity: 0
    })
    m.upgradeAccountLabel.update(m.upgAccMessageStyle)
    m.accountBadgeAnimation.update({
        duration: 0.6,
        optional: true
    })

    m.badgeBackgroundInterpolator.update({
        key: [0.0, 1.0],
        keyValue: [0, 1.0]
        fieldToInterp: "accountUpgradeBadge.opacity"
    })

    boudingRect = m.upgradeAccountLabel.boundingRect()
    m.upgradeAccountBackground.update(m.upgAccBackgroundStyle)
    m.upgradeAccountBackground.update({
        width: boudingRect.width + (m.upgradeAccountLabel.translation[0] * 2)
        height: boudingRect.height + (m.upgradeAccountLabel.translation[1] * 2)
    })

    itemSpacings = m.content.itemSpacings
    itemSpacings[itemSpacings.count() - 1] = Abs(itemSpacings[itemSpacings.count() - 1] - boudingRect.height)
    m.content.itemSpacings = itemSpacings

    m.content.insertChild(m.upgradeAccountBadge, m.content.getChildCount() - 1)

    m.btnPlay.observeField("focusedChild", "onBtnPlayFocus")
end sub

sub onBtnPlayFocus()
    startAnimation(m.accountBadgeAnimation, not m.btnPlay.isInFocusChain())
end sub

'*************************************************************************
'#region *** Key events
'*************************************************************************

function onScreenKeyPress(key, press) as boolean
    eventCaptured = false

    panelVisibleCondition = (key = "up" and m.panelVisible and m.episodes.isInFocusChain()) or (key = "down" and m.panelVisible and m.episodesPages.isInFocusChain())
    panelNotVisibleCondition = ((key = "up" or key = "down") and not m.panelVisible)

    if panelVisibleCondition or panelNotVisibleCondition
        startAnimation(m.panelAnimation, m.panelVisible)
        m.panelVisible = not m.panelVisible

        if m.panelVisible
            focusNode(m.episodes)
        else
            focusNode(m.buttons)
        end if

        eventCaptured = true
    else if (key = "up" or key = "down" or key = "right" or key = "left") and m.panelVisible
        'Focus episodes condition
        if (key = "up" or key = "left" or key = "right") and m.episodesPages.isInFocusChain()
            focusNode(m.episodes)
            eventCaptured = true
            'Focus pages condition
        else if (key = "down" or key = "left" or key = "right") and m.episodes.isInFocusChain()
            focusNode(m.episodesPages)
            eventCaptured = true
        end if
    else if key = "back"
        if m.panelVisible
            startAnimation(m.panelAnimation, true)
            focusNode(m.buttons)

            m.panelVisible = false
            eventCaptured = true
        else if m.isDeepLink = true
            eventCaptured = true
            clearStackAndNavigate("HomeScreen")
        end if
    end if

    return eventCaptured
end function
