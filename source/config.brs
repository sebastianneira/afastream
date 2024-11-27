function getConfig()
    menuIconPath = "pkg:/images/menu/"

    views = {
        startUp: "StartUpScreen"
        userStart: "UserStartScreen"
        home: "HomeScreen"
        categories: "CategoriesScreen"
        search: "SearchScreen"
        watchlist: "WatchlistScreen"
        account: "AccountScreen"
        landing: "LandingScreen"
    }

    screens = {
        startup: { id: "startup", view: views.Startup },
        landing: { id: "landing", view: views.landing },
        home: { id: "home", view: views.Home }
        categories: { id: "categories", view: views.categories },
        search: { id: "search", view: views.Search },
        watchlist: { id: "watchlist", view: views.watchlist },
        account: { id: "account", view: views.account },
        video: { id: "video", view: views.Video },
    }

    menu = [
        {
            screen: screens.home,
            title: UCase("Home"),
            icon: menuIconPath + "home.png"
        },
        {
            screen: screens.categories,
            title: UCase("Categories"),
            icon: menuIconPath + "categories.png"
        },
        {
            screen: screens.search,
            title: UCase("Search"),
            icon: menuIconPath + "search.png"
        },
        {
            screen: screens.watchlist,
            title: UCase("Watchlist"),
            icon: menuIconPath + "watchlist.png"
        },
        {
            screen: screens.account,
            title: UCase("Account"),
            icon: menuIconPath + "account.png"
        },
    ]

    settings = {
        environment: {
            environmentUrl: "https://stream.afa.net"
            environmentAPIUrl: "https://stream.afa.net/Umbraco/api/"
        }
        auth: {
            url: "https://afa-login.us.auth0.com/oauth/token"
            clientId: "OO7cu30WWrjiKNBzMv48BUYSlFdzkZWe"
            audience: "https://afa-login.us.auth0.com/api/v2/"
            scope: "openid profile offline_access email read:current_user update:current_user_metadata"
        }
        screenCleanModes: {
            stack: "stack",
            current: "current"
        }
        screenStates: {
            init: "init",
            revisit: "revisit",
            navBack: "navBack"
            inactive: "inactive",
            sleep: "sleep",
            closed: "closed"
        },
        screenMode: {
            screen: "screen",
            modal: "modal",
            alert: "alert"
        }
    }

    styles = {
        defaultRowList: {
            itemComponentName: "HomeTile"
            itemSize: [1374, 330]
            rowItemSize: [[210, 300]]
            rowItemSpacing: [[21, 0]]
            rowLabelOffset: [[0, 30]]
            showRowLabel: [true]
            drawFocusFeedback: true
            vertFocusAnimationStyle: "fixedFocusWrap"
            rowFocusAnimationStyle: "floatingFocus"
        }
        ctaBtn: {

        }
        secondaryBtn: {

        }
    }

    config = {
        menu: menu
        views: views
        settings: settings
        styles: styles
    }

    return config
end function
