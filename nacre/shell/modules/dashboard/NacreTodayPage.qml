import QtQuick
import QtQuick.Controls.Basic
import QtMultimedia
import qs.widgets
import qs.services

Flickable {
    id: root
    required property bool shouldUpdate
    required property var visibilities
    readonly property bool narrow: width < 650
    readonly property string heroVideoPath: /\.(mp4|webm|mkv|mov|m4v)$/i.test(NacreWallpapers.displayPreview) ? NacreWallpapers.displayPreview : NacreWallpapers.displayPath
    implicitWidth: 940
    implicitHeight: 550
    contentHeight: sections.height
    contentWidth: width
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: NacreScrollBar {}
    FastScroll {
        view: root
    }
    Column {
        id: sections
        width: root.width
        spacing: 18
        NacreDashboardHero {
            id: hero
            width: parent.width
            height: 254
            Image {
                anchors.fill: parent
                source: NacreWallpapers.poster ? "file://" + NacreWallpapers.poster : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                retainWhileLoading: true
                sourceSize.width: 1440
            }
            Loader {
                anchors.fill: parent
                active: root.shouldUpdate && NacreWallpapers.displayDynamic && !NacreWallpapers.displayAnimated && NacreTokens.motionEnabled && !WallpaperPlayback.batteryPaused && !WallpaperPlayback.paused && !WallpaperPlayback.sleeping && !WallpaperPlayback.locked
                sourceComponent: Item {
                    MediaPlayer {
                        id: video
                        objectName: "dashboardWallpaperVideo"
                        autoPlay: true
                        onMediaStatusChanged: if (mediaStatus === MediaPlayer.LoadedMedia)
                            play()
                        source: "file://" + root.heroVideoPath
                        loops: MediaPlayer.Infinite
                        videoOutput: videoSurface
                    }
                    VideoOutput {
                        id: videoSurface
                        anchors.fill: parent
                        fillMode: VideoOutput.PreserveAspectCrop
                    }
                }
            }
            AnimatedImage {
                anchors.fill: parent
                source: root.shouldUpdate && NacreWallpapers.displayDynamic && NacreWallpapers.displayAnimated ? "file://" + NacreWallpapers.displayPath : ""
                playing: root.shouldUpdate && NacreTokens.motionEnabled && !WallpaperPlayback.batteryPaused && !WallpaperPlayback.paused
                visible: status === Image.Ready
                fillMode: Image.PreserveAspectCrop
            }
            Rectangle {
                anchors.fill: parent
                color: "#11151b"
                opacity: .58
            }
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: "#0011151b"
                    }
                    GradientStop {
                        position: 1
                        color: "#a011151b"
                    }
                }
            }
            Column {
                x: 24
                y: 24
                width: parent.width - 48
                spacing: 10
                NacreText {
                    text: NacreTime.format("HH:mm")
                    font.pointSize: 44
                    font.weight: Font.Light
                    color: "#fffdfa"
                }
                NacreText {
                    text: NacreTime.format("dddd, d MMMM")
                    font.pointSize: 13
                    color: "#fffdfa"
                }
                Row {
                    spacing: 8
                    NacreIcon {
                        text: NacreWeather.icon
                        color: "#fffdfa"
                    }
                    NacreText {
                        text: NacreWeather.displayTemperature ? NacreWeather.displayTemperature + "  " + NacreWeather.description + " · " + NacreWeather.location : "Weather unavailable"
                        color: "#fffdfa"
                        font.pointSize: 11
                    }
                }
            }
            NacreText {
                anchors.right: parent.right
                anchors.rightMargin: 24
                y: 38
                text: NacreDashboardState.home.time ? "Home · " + NacreDashboardState.home.label + "  " + NacreDashboardState.home.time : ""
                color: "#fffdfa"
                font.pointSize: 11
                visible: !root.narrow
            }
            Row {
                x: 24
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 18
                spacing: 10
                Repeater {
                    model: [NacreColours.palette.m3primary, NacreColours.palette.m3secondary, NacreColours.palette.m3tertiary, NacreColours.palette.m3surfaceContainerHigh, NacreColours.palette.m3onSurface]
                    Rectangle {
                        required property var modelData
                        width: 19
                        height: 19
                        radius: 9.5
                        color: modelData
                        anchors.verticalCenter: parent.verticalCenter
                        NacreInteraction {
                            accessibleName: "Open wallpaper colors"
                            function onClicked() {
                                NacreColorsApp.open();
                            }
                        }
                    }
                }
                NacreText {
                    text: (NacreWallpapers.preferences.palettePersonality || "natural") + " · " + (NacreColours.light ? "Light" : "Dark")
                    color: "#fffdfa"
                    font.pointSize: 10
                    anchors.verticalCenter: parent.verticalCenter
                    visible: !root.narrow
                }
            }
            Column {
                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 12
                width: options.implicitWidth
                spacing: 6
                Row {
                    id: options
                    spacing: 6
                    ActionButton {
                        objectName: "dashboardWallpapers"
                        text: "Wallpapers"
                        icon: "wallpaper"
                        compact: true
                        onClicked: NacrePanelState.openMode("wallpaper")
                    }
                    ActionButton {
                        objectName: "dashboardColors"
                        text: "Colors"
                        icon: "palette"
                        compact: true
                        onClicked: NacreColorsApp.open()
                    }
                }
                NacreSurface {
                    objectName: "dashboardWallpaperTransport"
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width
                    height: 34
                    radius: 17
                    color: NacreTokens.raised
                    Item {
                        anchors.fill: parent
                        WallpaperControl {
                            objectName: "dashboardPreviousWallpaper"
                            icon: "chevron_left"
                            label: "Previous wallpaper"
                            available: NacreWallpapers.rotationReady
                            onActivated: NacreWallpapers.previousWallpaper()
                        }
                        WallpaperControl {
                            x: parent.width / 3
                            objectName: "dashboardPauseWallpaper"
                            icon: WallpaperPlayback.paused ? "play_arrow" : "pause"
                            label: WallpaperPlayback.paused ? "Resume wallpaper" : "Pause wallpaper"
                            visible: NacreWallpapers.displayDynamic
                            available: visible && !NacreWallpapers.themeBusy && !WallpaperPlayback.sleeping && !WallpaperPlayback.locked
                            onActivated: NacreWallpapers.toggleMotion()
                        }
                        WallpaperControl {
                            x: parent.width * 2 / 3
                            objectName: "dashboardNextWallpaper"
                            icon: "chevron_right"
                            label: "Next wallpaper"
                            available: NacreWallpapers.rotationReady
                            onActivated: NacreWallpapers.advanceRotation(true)
                        }
                    }
                }
            }
        }
        NacreDashboardSummary {
            objectName: "dashboardSummary"
            width: parent.width
            height: root.narrow ? implicitHeight : Math.max(288, root.height - hero.height - sections.spacing)
            active: root.shouldUpdate
            onSystemRequested: root.visibilities.dashboardTab = 3
        }
    }
    component WallpaperControl: Item {
        required property string icon
        required property string label
        property bool available: false
        signal activated
        width: parent.width / 3
        height: 34
        NacreIcon {
            anchors.centerIn: parent
            text: parent.icon
            font.pointSize: 16
            opacity: parent.available ? 1 : .4
        }
        NacreInteraction {
            id: interaction
            radius: 17
            disabled: !parent.available
            accessibleName: parent.label
            function onClicked(event) {
                if (event)
                    focus = false;
                parent.activated();
            }
        }
        ToolTip {
            id: tooltip
            visible: interaction.hovered && interaction.enabled
            delay: 500
            text: parent.label
            contentItem: NacreText {
                text: tooltip.text
                font.pointSize: 10
            }
            background: NacreSurface {
                color: NacreTokens.raised
                radius: 8
            }
        }
    }
}
