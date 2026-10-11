import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtMultimedia
import qs.widgets
import qs.services
import "overview" as Cards
import "media/media.js" as Media

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
                        source: "file://" + root.heroVideoPath
                        loops: MediaPlayer.Infinite
                        videoOutput: videoSurface
                        Component.onCompleted: play()
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
            Row {
                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 12
                spacing: 6
                ActionButton {
                    text: "Next"
                    icon: "skip_next"
                    compact: true
                    enabled: NacreWallpapers.rotationReady
                    onClicked: NacreWallpapers.rotate(true)
                }
                ActionButton {
                    text: "Colors"
                    icon: "palette"
                    compact: true
                    onClicked: NacreColorsApp.open()
                }
            }
        }
        GridLayout {
            width: parent.width
            columns: root.narrow ? 1 : NacrePlayers.active ? 3 : 2
            columnSpacing: 16
            rowSpacing: 16
            Cards.NacreCalendarCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 252
                Layout.preferredWidth: 300
                color: "transparent"
            }
            Column {
                Layout.fillWidth: true
                Layout.preferredWidth: 270
                Layout.alignment: Qt.AlignTop
                spacing: 12
                NacreText {
                    text: "Up next"
                    font.pointSize: 15
                    color: NacreTokens.accent
                }
                NacreText {
                    width: parent.width
                    text: NacreDashboardState.calendar.configured ? NacreDashboardState.calendar.events.length ? "" : "No upcoming events" : "Add a local calendar in dashboard options"
                    visible: text !== ""
                    wrapMode: Text.Wrap
                    color: NacreTokens.mutedInk
                    font.pointSize: 11
                }
                Repeater {
                    model: NacreDashboardState.calendar.events.slice(0, 3)
                    Column {
                        required property var modelData
                        width: parent.width
                        spacing: 4
                        NacreText {
                            text: parent.modelData.time + "  " + parent.modelData.date
                            font.pointSize: 9
                            color: NacreTokens.mutedInk
                        }
                        NacreText {
                            width: parent.width
                            text: parent.modelData.title
                            font.pointSize: 11
                            wrapMode: Text.Wrap
                        }
                    }
                }
                NacreText {
                    width: parent.width
                    text: NacreDashboardState.calendar.error || ""
                    visible: text !== ""
                    wrapMode: Text.Wrap
                    font.pointSize: 9
                    color: NacreTokens.mutedInk
                }
            }
            Cards.NacreMediaCard {
                visible: !!NacrePlayers.active
                Layout.fillWidth: true
                Layout.preferredWidth: 260
                Layout.preferredHeight: 252
                active: root.shouldUpdate
                color: "transparent"
            }
        }
        NacreText {
            width: parent.width
            text: "CPU " + Media.percent(NacreSystemUsage.cpuPerc) + "    RAM " + Media.percent(NacreSystemUsage.memPerc) + "    GPU " + (NacreSystemUsage.gpuUsageAvailable ? Media.percent(NacreSystemUsage.gpuPerc) : "—") + "     " + Updates.count + " updates"
            font.pointSize: 10
            color: NacreTokens.mutedInk
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
