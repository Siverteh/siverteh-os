import QtQuick
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Io
import qs.widgets
import qs.services
import "app-browser.js" as Catalog
import "calculator.js" as Calculator

NacreSurface {
    id: root
    required property PersistentProperties visibilities
    property string category: "favorites"
    property var contextEntry: null
    property bool keyboardSelection: false
    readonly property string query: search.text
    readonly property bool commands: query.trim().startsWith(">")
    readonly property var categories: Catalog.available(NacreApps.list)
    readonly property bool calculation: query.trim().startsWith("=")
    readonly property string activeCategory: commands ? "actions" : category
    readonly property bool actionLayout: !calculation && activeCategory === "actions"
    readonly property string searchTerm: commands || calculation ? query.trim().slice(1).trim() : query.trim()
    readonly property bool hasSelection: !!searchTerm || keyboardSelection
    readonly property var calculationResult: calculation ? Calculator.evaluate(searchTerm) : ({
            ok: false
        })
    readonly property var allActions: Catalog.actions(DesktopActions.list)
    readonly property var actions: allActions.filter(item => item.launcher !== false)
    readonly property var entries: {
        if (calculation)
            return calculationResult.ok ? [
                {
                    name: calculationResult.value,
                    description: "Enter to copy the result",
                    icon: "calculate",
                    kind: "calculation",
                    value: calculationResult.value
                }
            ] : [];
        if (commands || category === "actions")
            return Catalog.rankedActions(actions, searchTerm);
        if (query.trim())
            return NacreApps.fuzzyQuery(query.trim());
        if (category === "hidden")
            return NacreApps.all.filter(a => LauncherPreferences.hidden.includes(a.id));
        if (category === "favorites")
            return Catalog.alphabetical(LauncherPreferences.favorites.map(id => Catalog.favorite(id, NacreApps.list, allActions)).filter(Boolean));
        return category === "all" ? NacreApps.list : NacreApps.list.filter(a => Catalog.belongs(a, category));
    }
    implicitWidth: Math.min(980, Quickshell.screens[0].width - 90)
    implicitHeight: Math.min(5 * 119 + 106, Quickshell.screens[0].height - 170)
    radius: 22
    color: NacreColours.palette.m3surface
    function select(name) {
        category = name;
        keyboardSelection = false;
        search.text = "";
        selectFirst();
    }
    function reset() {
        category = "favorites";
        keyboardSelection = false;
        search.text = visibilities.launcherQuery || "";
        selectFirst();
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
        if (entry.kind === "calculation")
            AppLaunch.run(["wl-copy", "--", entry.value]);
        else if (entry.kind === "action")
            DesktopActions.execute(entry.action, entry.value);
        else
            NacreApps.launch(entry);
    }
    function favorite(entry) {
        if (entry?.id && entry.kind !== "calculation")
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
        if (!grid)
            return;
        grid.currentIndex = searchTerm && entries.length ? 0 : -1;
        grid.positionViewAtBeginning();
    }
    function focusResults() {
        keyboardSelection = true;
        if (grid.currentIndex < 0 && entries.length)
            grid.currentIndex = 0;
        grid.forceActiveFocus();
    }
    onQueryChanged: {
        keyboardSelection = false;
        selectFirst();
    }
    onEntriesChanged: {
        if (searchTerm)
            selectFirst();
        else if (!keyboardSelection)
            grid.currentIndex = -1;
        else if (grid.currentIndex >= entries.length)
            grid.currentIndex = entries.length ? entries.length - 1 : -1;
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
        currentIndex: Math.max(0, root.categories.findIndex(c => c.id === root.activeCategory))
        delegate: NacreSurface {
            required property var modelData
            required property int index
            width: rail.width
            height: 42
            radius: 12
            color: root.activeCategory === modelData.id ? NacreColours.palette.m3primaryContainer : "transparent"
            Row {
                anchors.verticalCenter: parent.verticalCenter
                x: 10
                spacing: 10
                NacreIcon {
                    text: parent.parent.modelData.icon
                    font.pointSize: 15
                    color: root.activeCategory === parent.parent.modelData.id ? NacreColours.palette.m3onPrimaryContainer : NacreColours.palette.m3onSurface
                }
                NacreText {
                    text: parent.parent.modelData.label
                    font.pointSize: 11
                    color: root.activeCategory === parent.parent.modelData.id ? NacreColours.palette.m3onPrimaryContainer : NacreColours.palette.m3onSurface
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
        Keys.onRightPressed: root.focusResults()
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
        text: root.calculation ? "Calculator" : root.actionLayout ? "Actions" : root.query.trim() ? "Search results" : root.category === "hidden" ? "Hidden applications" : root.categories.find(c => c.id === root.activeCategory)?.label || "Applications"
        font.pointSize: 13
    }
    NacreText {
        x: 380
        y: 18
        width: parent.width - x - 20
        horizontalAlignment: Text.AlignRight
        font.pointSize: 9
        color: NacreColours.palette.m3onSurfaceVariant
        text: root.calculation ? "Enter to copy" : root.actionLayout ? "Enter to run · Ctrl+D to favorite" : "> for actions · = for calculator"
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
        cellWidth: root.actionLayout ? width / (width >= 620 ? 2 : 1) : Math.max(116, width / Math.max(1, Math.floor(width / 140)))
        cellHeight: height / 5
        clip: true
        model: root.entries
        currentIndex: -1
        boundsBehavior: Flickable.StopAtBounds
        highlightMoveDuration: 0
        delegate: NacreSurface {
            id: tile
            required property var modelData
            required property int index
            objectName: "launcherTile_" + index
            readonly property bool actionEntry: modelData.kind === "action"
            readonly property bool utilityEntry: actionEntry || modelData.kind === "calculation"
            readonly property bool selected: grid.currentIndex === index && root.hasSelection
            readonly property real iconSize: Math.min(root.actionLayout ? 40 : 52, Math.max(24, grid.cellHeight - 64))
            readonly property bool aiApplication: !actionEntry && (modelData.id === "nacre-ai" || modelData.id === "nacre-ai.desktop") || (actionEntry && modelData.brand === "ai")
            readonly property bool brainApplication: !actionEntry && (modelData.id === "nacre-brain" || modelData.id === "nacre-brain.desktop") || (actionEntry && modelData.brand === "brain")
            readonly property bool colorsApplication: !actionEntry && (modelData.id === "nacre-colors" || modelData.id === "nacre-colors.desktop") || (actionEntry && modelData.brand === "colors")
            readonly property bool settingsApplication: !actionEntry && (modelData.id === "nacre-settings" || modelData.id === "nacre-settings.desktop") || (actionEntry && modelData.brand === "settings")
            readonly property bool welcomeApplication: (!actionEntry && (modelData.id === "nacre-welcome" || modelData.id === "nacre-welcome.desktop")) || (actionEntry && modelData.brand === "welcome")
            width: grid.cellWidth - 8
            height: grid.cellHeight - 8
            radius: 15
            color: tile.selected ? NacreColours.palette.m3primaryContainer : tileHover.hovered ? NacreColours.palette.m3surfaceContainerHigh : "transparent"
            HoverHandler {
                id: tileHover
            }
            Image {
                id: appIcon
                x: root.actionLayout ? 16 : (parent.width - width) / 2
                y: root.actionLayout ? (parent.height - height) / 2 : Math.min(12, grid.cellHeight * .1)
                width: tile.iconSize
                height: tile.iconSize
                source: !tile.utilityEntry && !tile.aiApplication && !tile.brainApplication && !tile.settingsApplication && !tile.colorsApplication && !tile.welcomeApplication ? Quickshell.iconPath(tile.modelData.icon, true) : ""
                asynchronous: true
                visible: !tile.utilityEntry && !tile.aiApplication && !tile.brainApplication && !tile.settingsApplication && !tile.colorsApplication && !tile.welcomeApplication && status === Image.Ready
                sourceSize.width: 52
                sourceSize.height: 52
            }
            BrandLogo {
                objectName: "nacreAiAppLogo"
                x: root.actionLayout ? 16 : (parent.width - width) / 2
                y: root.actionLayout ? (parent.height - height) / 2 : Math.min(12, grid.cellHeight * .1)
                width: tile.iconSize
                height: tile.iconSize
                ai: tile.aiApplication
                brain: tile.brainApplication
                settings: tile.settingsApplication
                colorsApp: tile.colorsApplication
                visible: tile.aiApplication || tile.brainApplication || tile.settingsApplication || tile.colorsApplication || tile.welcomeApplication
            }
            NacreIcon {
                x: root.actionLayout ? 16 : (parent.width - width) / 2
                y: root.actionLayout ? (parent.height - height) / 2 : Math.min(15, grid.cellHeight * .12)
                text: tile.utilityEntry ? tile.modelData.icon || "apps" : "apps"
                visible: !tile.aiApplication && !tile.brainApplication && !tile.settingsApplication && !tile.colorsApplication && !tile.welcomeApplication && (tile.utilityEntry || appIcon.status === Image.Error || appIcon.status === Image.Null)
                font.pointSize: tile.iconSize * .65
            }
            NacreText {
                x: root.actionLayout ? 72 : 8
                y: root.actionLayout ? 14 : Math.min(74, grid.cellHeight - 40)
                width: parent.width - x - (root.actionLayout ? 38 : 8)
                height: root.actionLayout ? 38 : Math.max(0, parent.height - y - 4)
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                horizontalAlignment: root.actionLayout ? Text.AlignLeft : Text.AlignHCenter
                text: tile.modelData.name
                font.pointSize: 10
                color: tile.selected ? NacreColours.palette.m3onPrimaryContainer : NacreColours.palette.m3onSurface
            }
            NacreText {
                x: 72
                y: 54
                width: parent.width - x - 16
                height: parent.height - y - 8
                visible: root.actionLayout
                wrapMode: Text.Wrap
                maximumLineCount: 2
                elide: Text.ElideRight
                text: tile.modelData.description || ""
                font.pointSize: 9
                color: tile.selected ? NacreColours.palette.m3onPrimaryContainer : NacreColours.palette.m3onSurfaceVariant
            }
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: event => {
                    root.keyboardSelection = true;
                    grid.currentIndex = tile.index;
                    if (event.button === Qt.RightButton && tile.modelData.kind !== "calculation") {
                        root.contextEntry = tile.modelData;
                        const point = tile.mapToItem(root, event.x, event.y);
                        context.x = Math.max(0, Math.min(root.width - context.width, point.x));
                        context.y = Math.max(0, Math.min(root.height - context.height, point.y));
                        context.open();
                    } else if (event.button === Qt.LeftButton)
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
                visible: tile.modelData.kind !== "calculation" && root.category !== "hidden" && (tileHover.hovered || LauncherPreferences.favorites.includes(tile.modelData.id))
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
        Keys.onReturnPressed: if (root.hasSelection)
            root.activate(currentIndex)
        Keys.onEscapePressed: root.visibilities.launcher = false
        Keys.onTabPressed: rail.forceActiveFocus()
        Keys.onPressed: event => {
            if (event.key === Qt.Key_D && event.modifiers & Qt.ControlModifier) {
                if (root.hasSelection)
                    root.favorite(root.entries[currentIndex]);
                event.accepted = true;
            } else if ([Qt.Key_Left, Qt.Key_Right, Qt.Key_Up, Qt.Key_Down, Qt.Key_Home, Qt.Key_End].includes(event.key)) {
                root.keyboardSelection = true;
                if (grid.currentIndex < 0 && root.entries.length) {
                    grid.currentIndex = event.key === Qt.Key_End ? root.entries.length - 1 : 0;
                    event.accepted = true;
                }
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
        width: parent.width - x - 20
        wrapMode: Text.Wrap
        text: root.calculation ? root.calculationResult.error || "" : root.category === "favorites" && !root.query ? "Add apps or actions with their heart button" : "No matches"
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
        placeholderText: root.calculation ? "= (12 + 8) / 5" : root.actionLayout ? "Search actions" : "Search apps · > actions · = calculator"
        Keys.onDownPressed: root.focusResults()
        Keys.onTabPressed: rail.forceActiveFocus()
        onAccepted: if (root.hasSelection)
            root.activate(grid.currentIndex)
        Keys.onPressed: event => {
            if (event.key === Qt.Key_D && event.modifiers & Qt.ControlModifier) {
                if (root.hasSelection)
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
                category: root.activeCategory,
                baseCategory: root.category,
                calculation: root.calculation,
                count: root.entries.length,
                query: root.query,
                columns: Math.max(1, Math.floor(grid.width / grid.cellWidth)),
                height: root.height,
                visibleRows: 5,
                currentIndex: root.hasSelection ? grid.currentIndex : -1,
                selectedId: root.hasSelection ? root.entries[grid.currentIndex]?.id || "" : "",
                names: root.entries.map(item => item.name),
                selectedName: root.hasSelection ? root.entries[grid.currentIndex]?.name || "" : ""
            });
        }
    }
}
