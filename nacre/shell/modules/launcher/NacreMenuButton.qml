import QtQuick
import qs.widgets
import qs.services

NacreSurface {
    id: root
    property string text: ""
    property string icon: ""
    property bool selected: false
    property bool compact: false
    signal clicked
    implicitHeight: compact ? 32 : 38
    implicitWidth: label.implicitWidth + 24 + (icon ? 25 : 0)
    radius: 9
    color: selected ? NacreColours.palette.m3primary : NacreColours.palette.m3surfaceContainerHigh
    opacity: enabled ? 1 : .5
    NacreIcon {
        id: glyph
        x: 11
        anchors.verticalCenter: parent.verticalCenter
        text: root.icon
        visible: !!root.icon
        font.pointSize: root.compact ? 12 : 14
        color: root.selected ? NacreColours.palette.m3onPrimary : NacreColours.palette.m3onSurface
    }
    NacreText {
        id: label
        x: root.icon ? 36 : 12
        width: Math.max(0, parent.width - x - 12)
        anchors.verticalCenter: parent.verticalCenter
        text: root.text
        textFormat: Text.PlainText
        font.pointSize: root.compact ? 10 : 11
        elide: Text.ElideRight
        color: root.selected ? NacreColours.palette.m3onPrimary : NacreColours.palette.m3onSurface
    }
    NacreInteraction {
        accessibleName: root.text || root.icon
        function onClicked() {
            root.clicked();
        }
    }
}
