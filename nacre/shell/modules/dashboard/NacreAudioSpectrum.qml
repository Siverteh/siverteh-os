import QtQuick
import qs.widgets
import qs.services

Item {
    id: root
    property var samples: NacreMediaDetails.spectrum
    property bool active: false
    property bool playing: NacrePlayers.active?.isPlaying === true
    readonly property bool animated: active && playing && NacreTokens.motionEnabled
    implicitHeight: 72
    Accessible.role: Accessible.Indicator
    Accessible.name: "Audio spectrum"
    function level(index) {
        if (!animated)
            return 0;
        const first = samples[index * 2], second = samples[index * 2 + 1];
        return Math.max(0, Math.min(1, Math.max(Number.isFinite(first) ? first : 0, Number.isFinite(second) ? second : 0)));
    }
    Row {
        anchors.fill: parent
        spacing: 5
        Repeater {
            model: 16
            Item {
                required property int index
                width: Math.max(0, (root.width - 75) / 16)
                height: root.height
                Rectangle {
                    objectName: "spectrumBar" + parent.index
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 2 + root.level(parent.index) * Math.max(0, root.height - 2)
                    radius: Math.min(width / 2, 4)
                    opacity: root.animated ? .9 : .18
                    gradient: Gradient {
                        GradientStop {
                            position: 0
                            color: NacreColours.palette.m3tertiary
                        }
                        GradientStop {
                            position: .5
                            color: NacreTokens.orientSecondary
                        }
                        GradientStop {
                            position: 1
                            color: NacreTokens.accent
                        }
                    }
                    Behavior on height {
                        NumberAnimation {
                            duration: root.animated ? 90 : NacreTokens.motionEnabled ? 160 : 0
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
