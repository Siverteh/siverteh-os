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

Typing searches visible apps and highlights the top-ranked result while the
search field keeps keyboard focus. Enter launches that selection; arrows let
you choose another. Actions sits directly below Favorites and lists the same
built-in actions as `>` search. Within Actions, typing filters actions.

Apps and actions share the heart, right-click favorite menu and Ctrl+D toggle
(including while typing). Favorites can mix both in the saved order. Action IDs
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
