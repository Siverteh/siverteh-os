# Nacre launcher and wallpaper presentation

Date: 2026-10-09. Next area after the verified independent frame.
[Feature behavior](../features/launcher.md) · [Wallpapers](../features/wallpapers.md)
· [Whole-tree tracker](../nacre/PROVENANCE.md).

## Outcome and origin boundary

Remove inherited launcher assembly, list/action/wallpaper-item implementations and
any inherited remnants in the maintained app/wallpaper presentation. Build fresh
from this spec, consumer contracts, runtime observations and dependency APIs.
Do not inspect upstream or local target implementation bodies while writing
replacements. Prior wrapper/API exposure during frame integration is recorded;
no clean-room legal guarantee is claimed. Keep all applicable notices until the
whole-current-tree audit is complete. Git creation alone is not origin proof.

Separate the inherited reference-era Content/ContentList/AppList/AppItem/Actions/
ActionItem/WallpaperList/WallpaperItem and Wrapper from the newer locally maintained
AppGrid, WallpaperGallery/Hex/Backdrop/MotionPreview and launcher.js. Inspect their
origin evidence and dependencies explicitly. Retain independently authored work
with evidence; replace mixed/uncertain implementation rather than certifying it
from filenames or formatting. Behavior tests and current private preferences are
contracts, not inherited source to copy.

## Launcher panel ownership

One screen-local launcher panel owns loading and presentation of apps, wallpaper,
command palette, overview, clipboard and shortcut search. Preserve visibility and
launcherMode/query/request properties, galleryCount/index/step API, source/IPC
routes, private recovery snapshots, escape and the frame's outside-click behavior.
Transient presentation never starts another app/theme/notification service.

Load expensive content only while open/closing. Keep fixed internal content height
through dismissal and clip at animated panel bounds. New requests reset relevant
selection/search and safely focus the intended input, without pinning AI. Reversing
open/close targets the latest state; reduced motion settles directly. Full-screen
wallpaper modes use the available viewport and their own dimmed backdrop; ordinary
app/carousel modes remain clean bottom panels. Preserve named object contracts used
by recovery, not a particular inherited internal object tree.

## Application browsing and actions

Super+A opens Favorites at a constant five-row height. All categories, Actions,
search and empty results retain that height. Smaller outputs scale the row/icon
height to fit five rows. Search stays anchored at the bottom. Categories reflect
installed desktop entries; omit empty app categories and honor hidden apps.

Search ranks visible apps, visibly selects the best result while typing and
Enter launches it without a click. Keep arrows, Tab, Escape and fast scrolling.
Actions follows Favorites in the rail and exposes the registered `>` actions;
its ordinary text search filters those actions. Power controls stay separate.
Heart/context-menu/Ctrl+D support both apps and actions, including from search.
Use stable namespaced operation/argument IDs in the existing private favorites
array; mixed favorites retain order, dynamic labels update, unknown IDs cannot
execute. Hide/restore applies only to apps. Category/search changes select the
first result; favorite changes must not reset unrelated All-app navigation.
Maintain existing preference locking/permissions and systemd/UWSM launch owner.
No arbitrary shell text, second preference owner or service.

## Wallpaper views

Super+W opens a dedicated wallpaper picker without app commands or power controls.
Static/Dynamic filters never duplicate media into both lists. Search names/paths,
arrow/wheel/chevron/Enter browsing, selected-tile silent animated preview, import/
drop and per-image accent preferences continue through existing backend owners.
Normal carousel retains complete odd card counts and smooth movement. Spotlight
spans the viewport with a large centered image and interpolated neighbors;
hexagons show rounded/hexagonal hit areas and a bounded viewport decode buffer.
Controls align centrally; no extra close button or oversized side boxes.

Reuse cached thumbnails/previews/posters and match palette/media publication.
Keep old loaded pixels until replacements are ready; no black startup/change
frames. Coalesce selection and redraw work; decode size must not churn during
geometry animation. Only the selected moving tile plays, without audio; stop
hidden previews/decoders. Respect wallpaper motion/rotation preferences and
reduced motion. Settings uses the same caches; no new idle polling/preparation.

## Acceptance and migration

Use actual replacement QML/JS in tests: fixed five-row geometry, category/search,
favorites/hiding/restore, key/pointer navigation, action dispatch, empty/removed
entries, open/close/focus/teardown, wallpaper filters/layout selection/navigation,
hex hit masks, image-ready retention and private preference preservation.

Prefer production helpers with fake data providers; assert native rendering where
shape or animation fidelity matters. Frame-only tests cannot certify launcher
behavior. Run full checks, target Hyprland verification, install plan/apply with
rollback, actual source/IPC and launcher/wallpaper Escape/off-click gates. Inspect
current native layouts in multiple modes/scales where available. Preserve busy
workers/accounts, cached private art and all other task worktrees. Record exact
replacement paths, commits, references, dependencies, origin evidence and limits;
then promote/push to existing main. Public extraction/visual redesign remain later.
