import QtQuick
import QtTest
import "fixtures"
import "calculator.js" as Arithmetic

TestCase {
    id: test

    function init() {
        LauncherPreferences.favorites = [];
        LauncherPreferences.hidden = [];
        NacreApps.launched = "";
        DesktopActions.executed = [];
        AppLaunch.commands = [];
        NacrePanelState.calls = [];
    }

    function test_category_browsing_and_global_search() {
        const view = createTemporaryObject(launcher, test);
        wait(30);
        compare(view.category, "favorites");
        compare(view.entries.length, 0);
        view.select("all");
        verify(!findChild(view, "launcherApps").currentItem || !findChild(view, "launcherApps").currentItem.selected);
        compare(view.entries.length, 3);
        verify(!view.categories.some(c => {
            return c.id === "games";
        }));
        view.select("development");
        compare(view.entries.length, 1);
        compare(view.entries[0].id, "editor");
        const input = findChild(view, "launcherSearch");
        input.text = "Music";
        compare(view.entries.length, 1);
        compare(view.entries[0].id, "music");
        input.text = ">";
        compare(view.entries.length, 3);
        compare(view.entries[0].action, "settings");
    }

    function test_ai_app_uses_live_logo_only_for_its_own_tile() {
        const original = NacreApps.all;
        try {
            for (const id of ["nacre-ai", "nacre-ai.desktop", "nacre-brain", "nacre-brain.desktop", "nacre-settings", "nacre-settings.desktop", "other-app"]) {
                NacreApps.all = [
                    {
                        id: id,
                        name: "Application",
                        categories: [],
                        icon: ""
                    }
                ];
                const view = createTemporaryObject(launcher, test);
                view.select("all");
                wait(30);
                const logo = findChild(view, "nacreAiAppLogo");
                verify(logo !== null);
                compare(logo.ai, id.startsWith("nacre-ai"));
                compare(logo.brain, id.startsWith("nacre-brain"));
                compare(logo.settings, id.startsWith("nacre-settings"));
                compare(logo.visible, id !== "other-app");
                view.destroy();
            }
        } finally {
            NacreApps.all = original;
        }
    }

    function test_favorites_hidden_and_restore() {
        LauncherPreferences.favorites = ["music"];
        const view = createTemporaryObject(launcher, test);
        wait(30);
        compare(view.category, "favorites");
        compare(view.entries.length, 1);
        LauncherPreferences.hidden = ["music"];
        compare(view.entries.length, 0);
        view.select("all");
        compare(view.entries.length, 2);
        view.select("hidden");
        compare(view.entries.length, 1);
        LauncherPreferences.hidden = [];
        view.select("all");
        compare(view.entries.length, 3);
    }

    function test_keyboard_navigation_and_escape() {
        const view = createTemporaryObject(launcher, test);
        wait(30);
        const input = findChild(view, "launcherSearch");
        const grid = findChild(view, "launcherApps");
        input.forceActiveFocus();
        keyClick(Qt.Key_Down);
        verify(grid.activeFocus);
        keyClick(Qt.Key_Left);
        keyClick(Qt.Key_Right);
        keyClick(Qt.Key_M);
        wait(20);
        compare(input.text, "m");
        verify(input.activeFocus);
        keyClick(Qt.Key_Escape);
        compare(view.visibilities.launcher, false);
    }

    function test_favorite_change_keeps_all_apps_selection() {
        const view = createTemporaryObject(launcher, test);
        wait(30);
        view.select("all");
        wait(20);
        const grid = findChild(view, "launcherApps");
        grid.currentIndex = 2;
        LauncherPreferences.update("favorite", "editor", true);
        wait(30);
        compare(grid.currentIndex, 2);
    }

    function test_five_rows_in_every_category_and_search() {
        const view = createTemporaryObject(launcher, test);
        wait(30);
        const expected = view.height;
        const search = findChild(view, "launcherSearch");
        const grid = findChild(view, "launcherApps");
        compare(grid.height, 5 * grid.cellHeight);
        const bottomGap = view.height - search.y - search.height;
        for (const category of ["favorites", "actions", "all", "development", "hidden"]) {
            view.select(category);
            wait(10);
            compare(view.height, expected);
            compare(grid.height, 5 * grid.cellHeight);
            compare(view.height - search.y - search.height, bottomGap);
        }
        search.text = "Music";
        compare(view.height, expected);
        search.text = "nothing matches";
        compare(view.height, expected);
        compare(grid.currentIndex, -1);
        view.visibilities.launcher = false;
        view.visibilities.launcher = true;
        wait(30);
        compare(view.category, "favorites");
        compare(view.height, expected);
        compare(search.text, "");
        view.select("all");
        view.height = 550;
        wait(30);
        compare(grid.height, 5 * grid.cellHeight);
        view.focusResults();
        const tile = grid.currentItem;
        verify(tile.height < 119);
        for (const child of tile.children) {
            if (child.visible && typeof child.height === "number")
                verify(child.y + child.height <= tile.height + .1);
        }
    }

    function test_typing_highlights_best_result_and_enter_launches() {
        const original = NacreApps.all;
        try {
            NacreApps.all = [
                {
                    id: "google-chrome",
                    name: "Google Chrome",
                    categories: [],
                    icon: ""
                },
                {
                    id: "google-beta",
                    name: "Google Chrome Beta",
                    categories: [],
                    icon: ""
                }
            ];
            const view = createTemporaryObject(launcher, test);
            wait(30);
            const input = findChild(view, "launcherSearch");
            input.forceActiveFocus();
            for (const letter of [Qt.Key_G, Qt.Key_O, Qt.Key_O, Qt.Key_G, Qt.Key_L, Qt.Key_E])
                keyClick(letter);
            wait(20);
            const grid = findChild(view, "launcherApps");
            compare(grid.currentIndex, 0);
            verify(input.activeFocus);
            verify(grid.currentItem.selected);
            compare(grid.currentItem.color, NacreColours.palette.m3primaryContainer);
            keyClick(Qt.Key_Return);
            compare(NacreApps.launched, "google-chrome");
            compare(view.visibilities.launcher, false);
        } finally {
            NacreApps.all = original;
        }
    }

    function test_action_rail_favorites_and_typed_actions_dispatch() {
        const view = createTemporaryObject(launcher, test);
        wait(30);
        compare(view.categories[0].id, "favorites");
        compare(view.categories[1].id, "actions");
        view.select("actions");
        compare(view.entries.length, 3);
        verify(!view.entries.some(item => item.action === "power"));
        const action = view.entries.find(item => item.value === "blur");
        verify(action !== null);
        view.favorite(action);
        view.favorite(NacreApps.list.find(item => item.id === "music"));
        view.select("favorites");
        compare(view.entries.length, 2);
        compare(view.entries[0].kind, "action");
        compare(view.entries[1].id, "music");
        view.activate(0);
        compare(DesktopActions.executed[0], "toggle-setting");
        compare(DesktopActions.executed[1], "blur");
        view.visibilities.launcher = true;
        const input = findChild(view, "launcherSearch");
        input.text = ">settings";
        compare(view.entries.length, 1);
        input.forceActiveFocus();
        keyClick(Qt.Key_D, Qt.ControlModifier);
        verify(LauncherPreferences.favorites.includes(view.entries[0].id));
        keyClick(Qt.Key_Return);
        compare(DesktopActions.executed[0], "settings");
        const original = DesktopActions.list;
        try {
            DesktopActions.list = original.map(item => item.value === "blur" ? Object.assign({}, item, {
                    name: "Enable blur"
                }) : item);
            view.select("favorites");
            compare(view.entries[0].id, action.id);
            compare(view.entries[0].name, "Enable blur");
        } finally {
            DesktopActions.list = original;
        }
        LauncherPreferences.favorites = ["nacre-action:missing:", "music"];
        compare(view.entries.length, 1);
        compare(view.entries[0].id, "music");
    }

    function test_alphabetical_and_no_browse_selection() {
        LauncherPreferences.favorites = ["music", "editor", "browser"];
        const view = createTemporaryObject(launcher, test);
        wait(30);
        compare(view.entries.map(item => item.name).join(","), "Browser,Editor,Music");
        const grid = findChild(view, "launcherApps");
        compare(grid.currentIndex, -1);
        const input = findChild(view, "launcherSearch");
        input.forceActiveFocus();
        keyClick(Qt.Key_Return);
        compare(NacreApps.launched, "");
        input.text = "Music";
        compare(grid.currentIndex, 0);
        verify(grid.currentItem.selected);
        input.text = "";
        verify(!grid.currentItem || !grid.currentItem.selected);
        keyClick(Qt.Key_Down);
        compare(grid.currentIndex, 0);
        verify(grid.currentItem.selected);
        view.select("all");
        verify(!grid.currentItem || !grid.currentItem.selected);
    }
    function test_prefix_mode_restores_prior_tab_and_action_ranking() {
        const view = createTemporaryObject(launcher, test);
        wait(30);
        view.select("development");
        const input = findChild(view, "launcherSearch");
        input.text = ">";
        compare(view.activeCategory, "actions");
        compare(view.category, "development");
        verify(!findChild(view, "launcherApps").currentItem || !findChild(view, "launcherApps").currentItem.selected);
        input.text = ">settings";
        compare(view.entries[0].action, "settings");
        compare(findChild(view, "launcherApps").currentIndex, 0);
        input.text = "";
        compare(view.activeCategory, "development");
        verify(!findChild(view, "launcherApps").currentItem || !findChild(view, "launcherApps").currentItem.selected);
    }
    function test_curated_catalog_routes_and_legacy_favorites() {
        const view = createTemporaryObject(launcher, test);
        wait(30);
        const original = DesktopActions.list;
        try {
            DesktopActions.list = ActualDesktopActions.list;
            view.select("actions");
            compare(view.entries.length, 21);
            compare(view.entries[0].action, "wallpaper");
            compare(view.entries[1].action, "calculator");
            findChild(view, "launcherSearch").text = ">open";
            compare(view.entries[0].action, "wallpaper");
            findChild(view, "launcherSearch").text = ">";
            compare(view.entries[0].action, "wallpaper");
            verify(!view.entries.some(item => ["preset", "toggle-setting", "light", "dark", "power", "left"].includes(item.action)));
            const input = findChild(view, "launcherSearch");
            input.text = ">ai";
            compare(view.entries[0].action, "tasks");
            input.text = ">brain";
            compare(view.entries[0].action, "brain");
            input.text = ">wifi";
            compare(view.entries[0].action, "wifi");
            LauncherPreferences.favorites = ["nacre-action:toggle-setting:blur"];
            view.select("favorites");
            compare(view.entries.length, 1);
            ActualDesktopActions.execute("colors");
            verify(NacreColorsApp.opened);
            ActualDesktopActions.execute("welcome");
            compare(NacreWelcomeApp.page, "home");
            ActualDesktopActions.execute("sound");
            compare(NacrePanelState.calls[NacrePanelState.calls.length - 1][1], "sound");
            ActualDesktopActions.execute("calculator");
            compare(NacrePanelState.calls[NacrePanelState.calls.length - 1].join(","), "apps,= ");
            ActualDesktopActions.execute("files");
            compare(AppLaunch.commands[0].join(","), "nacre-app,files");
        } finally {
            DesktopActions.list = original;
        }
    }
    function test_calculator_grammar_and_copy() {
        for (const pair of [["(12+8)/5", "4"], ["2+3*4", "14"], ["-2^2", "-4"], ["2^3^2", "512"], ["sqrt(81)+abs(-2)", "11"], ["0.1+0.2", "0.3"], ["1e3/4", "250"], ["log10(100)", "2"]]) {
            const result = Arithmetic.evaluate(pair[0]);
            verify(result.ok, result.error);
            compare(result.value, pair[1]);
        }
        for (const input of ["1/0", "sqrt(-1)", "1+", "(()=>7)()", "Math.random()", "constructor(1)", "(".repeat(40) + "1" + ")".repeat(40)])
            verify(!Arithmetic.evaluate(input).ok, input);
        const view = createTemporaryObject(launcher, test);
        wait(30);
        view.visibilities.launcherQuery = "= ";
        view.reset();
        verify(view.calculation);
        compare(view.entries.length, 0);
        const input = findChild(view, "launcherSearch");
        input.text = "= (12+8)/5";
        compare(view.entries[0].name, "4");
        input.forceActiveFocus();
        keyClick(Qt.Key_Return);
        compare(AppLaunch.commands[0].join(","), "wl-copy,--,4");
        compare(view.visibilities.launcher, false);
    }

    name: "CategorizedLauncher"
    width: 980
    height: 740
    visible: true
    when: windowShown

    Component {
        id: launcher

        NacreAppBrowser {
            width: 980
            height: implicitHeight

            visibilities: QtObject {
                property bool launcher: true
                property string launcherQuery: ""
            }
        }
    }
}
