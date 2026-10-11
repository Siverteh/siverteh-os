# Launcher

[System overview](../overview.md) · [Deployment and recovery](../maintenance.md)

## Categorized bottom launcher

Super+A toggles Apps. Super by itself has no launcher binding, avoiding
accidental opens. Super+W opens Wallpaper directly. The bottom drawer has no
hover trigger.

The app browser always has five rows, whether in Favorites, All apps, a category,
Actions or search. Smaller outputs scale row/icon height to keep the same five
slots within the viewport; the bottom search field stays anchored. Categories
come from desktop-entry metadata and empty app categories are omitted.

Favorites are displayed alphabetically by their current name, without rewriting
the private stored IDs. Opening/browsing has no selected app; arrow navigation
selects one deliberately. Typing searches visible apps and highlights the top-ranked result while the
search field keeps keyboard focus. Enter launches that selection; arrows let
you choose another. Actions sits directly below Favorites. Typing `>` visibly switches to Actions;
clearing the prefix returns to the prior category. Its two-column descriptive
rows expose 21 curated commands, including wallpaper, calculator, Nacre apps,
files/terminal, clipboard, overview, shortcuts, AI chat/note tools and device settings.
Search matches names, aliases and operation words; exact shortcuts like `>ai`,
`>brain` and `>wifi` favor the relevant destination. AI/note commands name their
Nacre product explicitly and use its live logo. Visual-effect toggles, palettes
and workflow presets live in Settings rather than crowding this list. Saved
favorites for those older operations still resolve and run.

Apps and actions share the heart, right-click favorite menu and Ctrl+D toggle
(including while typing). Favorites mix apps and actions alphabetically. Action IDs
are based on the operation and argument, so an Enable/Disable label change keeps
the favorite. Unavailable saved IDs are skipped; saved data never becomes an
arbitrary command. Application hiding/restoration remains app-only.
Tab moves into the category rail; Escape closes. Clicking outside dismisses the
panel without activating the app behind it. Power controls remain in their
existing menu.

Preferences are private atomic JSON in `~/.config/nacre/launcher.json`,
with mode 0600 and locked read/modify/write operations. They are outside source
and desktop rollback, and malformed data is preserved rather than overwritten.
The browser loads only while open/closing and uses the shared fast scrolling.


## Independent mode assembly

NacreLauncherPanel owns mode selection and lazy loading. It keeps loaded content
at a fixed internal height while the visible panel closes, clips that content,
and unloads it once the close transition settles. Reopening during a close targets
the latest state. Full-screen wallpaper modes use the existing viewport/backdrop
contract; gallery index/count/step and output recovery remain compatible.

The inherited reference-era content/list/action/item stack is removed. Its
compatibility `legacy` mode now uses the independently authored NacreSearchPanel:
app search or `>` known desktop actions, keyboard selection/Enter/Escape and
readable palette-aware rows. It does not execute arbitrary command text or add
power controls. The category browser now uses NacreAppBrowser and app-browser.js; these are fresh
implementations from the behavior spec and actual consumer/tests, not renamed
view bodies. Wallpaper presentation is independently replaced as well.

## Calculator

Choose Calculator in Actions, or type `= (12 + 8) / 5`. The result is selected
and Enter copies it to the clipboard. An empty calculator shows a usage hint;
incomplete or invalid expressions stay open with an explanation. Supported:
`+ - * / % ^ **`, parentheses, scientific notation, `pi`, `e`, `sqrt`, `abs`,
`sin`, `cos`, `tan`, `log` (natural log), `log10`, `floor`, `ceil`, `round`.
Trigonometry uses radians; `%` is remainder. Results use ordinary double precision,
formatted to 14 significant digits. No currency/unit conversion or history.

The independently authored bounded arithmetic grammar in `calculator.js` accepts
no JavaScript/shell evaluation. It runs only on query changes and shares the
existing launcher and clipboard launch owner; no new daemon or package is needed.
Normal blank search/`>` does not launch a hidden first item on Enter.

Design research: [Noctalia's provider documentation](https://github.com/noctalia-dev/noctalia/blob/main/docs/user/launcher/index.mdx)
explains explicit prefix scopes and descriptive rows for mixed results;
[Raycast's action panel](https://manual.raycast.com/action-panel) keeps contextual
options attached to results. Nacre keeps its five-row frame, app grid and stable
favorite IDs, with descriptive command rows and an explicit `=` calculator.
Only documentation was consulted; no external implementation was copied.

Command ordering is explicit: blank Actions retains the curated catalog order;
search ties retain that order through an index tie-breaker rather than relying
on the Qt JavaScript engine to implement stable sort.
