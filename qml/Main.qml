import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Content 1.1
import Ubuntu.DownloadManager 1.2
import Ubuntu.Components.Popups 1.3
import QtSystemInfo 5.0
import Qt.labs.settings 1.0

import "ui"
import "components"

MainView {
    id: mainView
    objectName: "mainView"
    applicationName: "wallpapers.eder"

    automaticOrientation: true

    width: units.gu(50)
    height: units.gu(75)

    // Landscape check
    readonly property bool isLandscape: width > height

    // API
    property string auth_key: "e522154190df97ef28c61f372e7e27b1"
    property string api_url: 'https://wall.alphacoders.com/api2.0/get.php'

    // App version
    property string current_version: "0.1.2"

    // Test
    property bool is_transfer: false
    property var transfer: null

    property bool downloading: false

    // Startup settings
    Settings {
        id: settings
    }

    // Navigation Menu Actions
    property list<Action> navActions: [
        Action {
            objectName: "wallpapersTabAction"
            text: i18n.tr("Wallpapers")
            iconName: "stock_image"
            onTriggered: {
                tabs.selectedTabIndex = 0
            }
        },
        Action {
            objectName: "aboutTabAction"
            text: i18n.tr("About")
            iconName: "info"
            onTriggered: {
                tabs.selectedTabIndex = 1
            }
        }
    ]

    // Main Actions for page header
    actions: [
        Action {
            id: searchAction
            text: i18n.tr("Search")
            iconName: "search"
            onTriggered: {
                wallpapersPage.state = "search"
            }
        },
        Action {
            id: filterAction
            text: i18n.tr("Filter")
            iconName: "filters"
            onTriggered: {
                wallpapersPage.state = "default"

                pageStack.push(filtersPage)
            }
        }
    ]

    Component.onCompleted: {
        start()
    }

    function start() {
        pageStack.clear()
        init()
    }

    function init() {
        pageStack.push(tabs)
    }

    PageStack {
        id: pageStack
    }

    Tabs {
        id: tabs
        visible: false

        Tab {
            id: homeTab

            WallpapersPage {
                id: wallpapersPage
            }
        }

        Tab {
            id: aboutTab

            AboutPage {
                id: aboutPage
            }
        }
    }

    FiltersPage {
        id: filtersPage
        visible: false
    }

    Component {
        id: photoSelectorResultComponent
        ContentItem {}
    }

    // Share to Wallpapers
    Connections {
        target: ContentHub
        onExportRequested: {
            mainView.transfer = transfer
            mainView.is_transfer = true
        }
    }

    // Download & Share to others
    ContentStore {
        id: appStore
        scope: ContentScope.App
    }

    Component {
        id: downloadComponent
        SingleDownload {
            autoStart: false
            property var contentType
            onDownloadIdChanged: {
                PopupUtils.open(downloadDialog, mainView, {"contentType" : contentType, "downloadId" : downloadId})
            }

            onFinished: {
                destroy()
            }
        }
    }

    SingleDownload {
        id: downloadManager

        onFinished: {
            mainView.downloading = false

            path = 'file://' + path;
            var photo_urls = [path]

            var results = photo_urls.map(function(photoUrl) {
                return photoSelectorResultComponent.createObject(mainView, {"url": photoUrl})
            })

            mainView.transfer.items = results
            mainView.transfer.state = ContentTransfer.Charged
            mainView.transfer = null

            mainView.is_transfer = false
        }
    }

    Component {
        id: downloadDialog
        ContentDownloadDialog { }
    }
}
