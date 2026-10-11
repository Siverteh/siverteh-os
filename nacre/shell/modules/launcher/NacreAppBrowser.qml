import QtQuick
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Io
import qs.widgets
import qs.services
import "app-browser.js" as Catalog

NacreSurface {
    id: root
    required property PersistentProperties visibilities
    property string category: "favorites"
    property var contextEntry: null
    readonly property string query: search.text
    readonly property bool commands: query.trim().startsWith(">")
    readonly property var categories: Catalog.available(NacreApps.list)
    readonly property var actions: Catalog.actions(DesktopActions.list)
    readonly property var entries: {
        if (commands || category === "actions")
            return actions.filter(a => Catalog.matches(a, commands ? query.trim().slice(1) : query.trim()));
        if (query.trim())
            return NacreApps.fuzzyQuery(query.trim());
        if (category === "hidden")
            return NacreApps.all.filter(a => LauncherPreferences.hidden.includes(a.id));
        if (category === "favorites")
            return LauncherPreferences.favorites.map(id => Catalog.favorite(id, NacreApps.list, actions)).filter(Boolean);
        return category === "all" ? NacreApps.list : NacreApps.list.filter(a => Catalog.belongs(a, category));
    }
    implicitWidth: Math.min(980, Quickshell.screens[0].width - 90)
    implicitHeight: Math.min(5 * 119 + 106, Quickshell.screens[0].height - 170)
    radius: 22
    color: NacreColours.palette.m3surface
    function select(name) {
        category = name;
        search.text = "";
        grid.currentIndex = 0;
    }
    function reset() {
        category = "favorites";
        search.text = "";
        grid.currentIndex = 0;
        search.forceActiveFocus();
    }
    function activate(index) {
        const entry = entries[index];
        if (!entry)
            return;
        if (category === "hidden" && !query.trim()) {
            LauncherPreferences.update("hide", entry.id, false);
            return;
        }
        visibilities.launcher = false;
        if (entry.kind === "action")
            DesktopActions.execute(entry.action, entry.value);
        else
            NacreApps.launch(entry);
    }
    function favorite(entry) {
        if (entry?.id)
            LauncherPreferences.update("favorite", entry.id, !LauncherPreferences.favorites.includes(entry.id));
    }
    function type(event) {
        if (event.key === Qt.Key_Backspace) {
            search.text = search.text.slice(0, -1);
        } else if (event.text && !(event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier))) {
            search.text += event.text;
        } else
            return false;
        search.forceActiveFocus();
        return true;
    }
    function selectFirst() {
        grid.currentIndex = entries.length ? 0 : -1;
        grid.positionViewAtBeginning();
    }
    onQueryChanged: selectFirst()
    onEntriesChanged: {
        if (query.trim())
            selectFirst();
        else if (grid.currentIndex >= entries.length || grid.currentIndex < 0)
            grid.currentIndex = entries.length ? Math.max(0, Math.min(grid.currentIndex, entries.length - 1)) : -1;
    }
    Component.onCompleted: reset()
    Connections {
        target: root.visibilities
        function onLauncherChanged() {
            if (root.visibilities.launcher)
                root.reset();
        }
    }
    ListView {
        id: rail
        objectName: "launcherCategories"
        x: 12
        y: 12
        width: 174
        height: parent.height - 94
        model: root.categories
        clip: true
        currentIndex: Math.max(0, root.categories.findIndex(c => c.id === root.category))
        delegate: NacreSurface {
            required property var modelData
            required property int index
            width: rail.width
            height: 42
            radius: 12
            color: root.category === modelData.id ? NacreColours.palette.m3primaryContainer : "transparent"
            Row {
                anchors.verticalCenter: parent.verticalCenter
                x: 10
                spacing: 10
                NacreIcon {
                    text: parent.parent.modelData.icon
                    font.pointSize: 15
                    color: root.category === parent.parent.modelData.id ? NacreColours.palette.m3onPrimaryContainer : NacreColours.palette.m3onSurface
                }
                NacreText {
                    text: parent.parent.modelData.label
                    font.pointSize: 11
                    color: root.category === parent.parent.modelData.id ? NacreColours.palette.m3onPrimaryContainer : NacreColours.palette.m3onSurface
                }
            }
            NacreInteraction {
                function onClicked() {
                    root.select(parent.modelData.id);
                }
            }
        }
        Keys.onReturnPressed: if (currentItem)
            root.select(currentItem.modelData.id)
        Keys.onEscapePressed: root.visibilities.launcher = false
        Keys.onRightPressed: grid.forceActiveFocus()
        Keys.onPressed: event => {
            if (root.type(event))
                event.accepted = true;
        }
        FastScroll {
            view: rail
            step: 180
        }
    }
    NacreText {
        id: heading
        x: 204
        y: 15
        text: root.commands ? "Actions" : root.query.trim() ? "Search results" : root.category === "hidden" ? "Hidden applications" : root.categories.find(c => c.id === root.category)?.label || "Applications"
        font.pointSize: 13
    }
    ActionButton {
        x: 12
        y: parent.height - 74
        visible: LauncherPreferences.hidden.length > 0
        text: "Hidden apps"
        compact: true
        onClicked: root.select("hidden")
    }
    GridView {
        id: grid
        objectName: "launcherApps"
        x: 200
        y: 46
        width: parent.width - 216
        height: parent.height - 106
        cellWidth: Math.max(116, width / Math.max(1, Math.floor(width / 140)))
        cellHeight: height / 5
        clip: true
        model: root.entries
        currentIndex: 0
        boundsBehavior: Flickable.StopAtBounds
        highlightMoveDuration: 0
        delegate: NacreSurface {
            id: tile
            required property var modelData
            required property int index
            objectName: "launcherTile_" + index
            readonly property bool actionEntry: modelData.kind === "action"
            readonly property bool selected: grid.currentIndex === index
            readonly property real iconSize: Math.min(52, Math.max(24, grid.cellHeight - 64))
            readonly property bool aiApplication: !actionEntry && (modelData.id === "nacre-ai" || modelData.id === "nacre-ai.desktop")
            readonly property bool brainApplication: !actionEntry && (modelData.id === "nacre-brain" || modelData.id === "nacre-brain.desktop")
            readonly property bool colorsApplication: !actionEntry && (modelData.id === "nacre-colors" || modelData.id === "nacre-colors.desktop")
            readonly property bool settingsApplication: !actionEntry && (modelData.id === "nacre-settings" || modelData.id === "nacre-settings.desktop")
            width: grid.cellWidth - 8
            height: grid.cellHeight - 8
            radius: 15
            color: tile.selected ? NacreColours.palette.m3primaryContainer : tileHover.hovered ? NacreColours.palette.m3surfaceContainerHigh : "transparent"
            HoverHandler {
                id: tileHover
            }
            Image {
                id: appIcon
                x: (parent.width - width) / 2
                y: Math.min(12, grid.cellHeight * .1)
                width: tile.iconSize
                height: tile.iconSize
                source: !tile.actionEntry && !tile.aiApplication && !tile.brainApplication && !tile.settingsApplication && !tile.colorsApplication ? Quickshell.iconPath(tile.modelData.icon, true) : ""
                asynchronous: true
                visible: !tile.actionEntry && !tile.aiApplication && !tile.brainApplication && !tile.settingsApplication && !tile.colorsApplication && status === Image.Ready
                sourceSize.width: 52
                sourceSize.height: 52
            }
            BrandLogo {
                objectName: "nacreAiAppLogo"
                anchors.horizontalCenter: parent.horizontalCenter
                y: Math.min(12, grid.cellHeight * .1)
                width: tile.iconSize
                height: tile.iconSize
                ai: tile.aiApplication
                brain: tile.brainApplication
                settings: tile.settingsApplication
                colorsApp: tile.colorsApplication
                visible: tile.aiApplication || tile.brainApplication || tile.settingsApplication || tile.colorsApplication
            }
            NacreIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                y: Math.min(15, grid.cellHeight * .12)
                text: tile.actionEntry ? tile.modelData.icon || "apps" : "apps"
                visible: !tile.aiApplication && !tile.brainApplication && !tile.settingsApplication && !tile.colorsApplication && (tile.actionEntry || appIcon.status === Image.Error || appIcon.status === Image.Null)
                font.pointSize: tile.iconSize * .65
            }
            NacreText {
                x: 8
                y: Math.min(74, grid.cellHeight - 40)
                width: parent.width - 16
                height: Math.max(0, parent.height - y - 4)
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                text: tile.modelData.name
                font.pointSize: 10
                color: tile.selected ? NacreColours.palette.m3onPrimaryContainer : NacreColours.palette.m3onSurface
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: event => {
                    grid.currentIndex = tile.index;
                    if (event.button === Qt.RightButton) {
                        root.contextEntry = tile.modelData;
                        const point = tile.mapToItem(root, event.x, event.y);
                        context.x = Math.max(0, Math.min(root.width - context.width, point.x));
                        context.y = Math.max(0, Math.min(root.height - context.height, point.y));
                        context.open();
                    } else
                        root.activate(tile.index);
                }
            }
            NacreSurface {
                x: parent.width - 27
                y: 4
                width: 24
                height: 24
                radius: 12
                color: "transparent"
                visible: root.category !== "hidden" && (tileHover.hovered || LauncherPreferences.favorites.includes(tile.modelData.id))
                NacreIcon {
                    anchors.centerIn: parent
                    text: "favorite"
                    fill: LauncherPreferences.favorites.includes(tile.modelData.id) ? 1 : 0
                    font.pointSize: 13
                    color: NacreColours.palette.m3primary
                }
                NacreInteraction {
                    function onClicked() {
                        root.favorite(tile.modelData);
                    }
                }
            }
        }
        Keys.onReturnPressed: root.activate(currentIndex)
        Keys.onEscapePressed: root.visibilities.launcher = false
        Keys.onTabPressed: rail.forceActiveFocus()
        Keys.onPressed: event => {
            if (event.key === Qt.Key_D && event.modifiers & Qt.ControlModifier) {
                root.favorite(root.entries[currentIndex]);
                event.accepted = true;
            } else if (root.type(event))
                event.accepted = true;
        }
        FastScroll {
            view: grid
        }
    }
    NacreText {
        x: 214
        y: 78
        visible: !root.entries.length
        text: root.category === "favorites" && !root.query ? "Add apps or actions with their heart button" : "No matches"
        color: NacreColours.palette.m3onSurfaceVariant
        font.pointSize: 11
    }
    NacreTextField {
        id: search
        objectName: "launcherSearch"
        x: 16
        y: parent.height - 62
        width: parent.width - 32
        height: 46
        padding: 14
        placeholderText: root.category === "actions" ? "Search actions" : "Search apps or > actions"
        Keys.onDownPressed: grid.forceActiveFocus()
        Keys.onTabPressed: rail.forceActiveFocus()
        onAccepted: root.activate(Math.max(0, grid.currentIndex))
        Keys.onPressed: event => {
            if (event.key === Qt.Key_D && event.modifiers & Qt.ControlModifier) {
                root.favorite(root.entries[grid.currentIndex]);
                event.accepted = true;
            }
        }
        Keys.onEscapePressed: root.visibilities.launcher = false
    }
    Popup {
        id: context
        width: 190
        padding: 10
        background: NacreSurface {
            color: NacreColours.palette.m3surfaceContainerHigh
            radius: 14
            border.width: 1
            border.color: NacreColours.palette.m3outline
        }
        contentItem: Column {
            spacing: 6
            ActionButton {
                text: root.contextEntry && LauncherPreferences.favorites.includes(root.contextEntry.id) ? "Remove favorite" : "Add favorite"
                compact: true
                onClicked: {
                    root.favorite(root.contextEntry);
                    context.close();
                }
            }
            ActionButton {
                visible: root.contextEntry?.kind !== "action"
                text: root.category === "hidden" ? "Show application" : "Hide application"
                compact: true
                onClicked: {
                    if (root.contextEntry)
                        LauncherPreferences.update("hide", root.contextEntry.id, root.category !== "hidden");
                    context.close();
                }
            }
        }
    }
    IpcHandler {
        target: "appBrowser"
        function selectCategory(id: string): void {
            root.select(id);
        }
        function state(): string {
            return JSON.stringify({
                category: root.category,
                count: root.entries.length,
                query: root.query,
                columns: Math.max(1, Math.floor(grid.width / grid.cellWidth)),
                height: root.height,
                visibleRows: 5,
                currentIndex: grid.currentIndex,
                selectedId: root.entries[grid.currentIndex]?.id || ""
            });
        }
    }
}
