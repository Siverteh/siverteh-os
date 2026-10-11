# Nacre Welcome tour

Run `nacre-welcome` or open Welcome in the launcher. Five fixed-size pages use
Back/Next and clickable progress dots, with Enter to continue and Escape to close:

1. Welcome: logo and “Mother-of-pearl. Colors shaped by your wallpaper.”
2. Your colors: four small credited scenes, all eight color styles, dark/light
   icons and a live desktop/role strip. Choosing changes the real desktop through
   its existing publisher. A full-width live preview with labeled role swatches underneath show the committed colors.
   Open the other tools from the Apps page.
3. Getting around: scrollable shortcut groups read live from described Hyprland binds.
   Alternative keys share a flexible-height row. Missing bindings are not guessed.
4. Apps: Settings/Colors plus optional AI/Brain with honest setup guides.
5. Ready: centered selection recap, Help and Start using Nacre.

The launcher can reopen the same tour. `nacre-welcome colors`, `shortcuts`, `apps`,
`ready` or `help` jumps directly to a section; legacy `home` starts Welcome.
Automatic login startup happens once per installation. The locked claim owner
records `firstRunShown` only after successful activation; failed activation releases
the claim and can retry. Finishing a manual tour also suppresses automatic startup.
Legacy `showAtLogin: false` remains an opt-out, and manual launcher opens always work.
Closing/skipping does not auto-install anything or reset chosen colors. Existing
snapshot/publisher error protection and original animated-source restoration stay.
Rotation pauses throughout an active tour. Panels remain captionless resizable windows.
Pages move briefly only on navigation, honoring reduced motion; no idle teaser loop.

## Offline artwork and credits

After Rain by David Revoy (CC BY4), Forest Path by Folium Creations (CC BY4),
Blue Orbit and Red Jungle by Nick Nazzaro/System76 (CC BY-SA4) provide warm, green,
purple and red scenes. Full original titles, native dimensions, download/source
URLs, checksums and licenses ship under `nacre/shell-tools/demo-wallpapers/`.
Credits link from each card. Two large PNGs use lossless WebP storage with original
RGB pixels/native dimensions verified identical; no upscaling/recoloring/AI art.
The helper repairs immutable cached copies offline and never overwrites the
personal library. These explicitly licensed assets are the narrow image exception.

Private0600 per-opening baselines retain at most10 records. Validated restoration
uses classic-state's existing publication lock and preserves unrelated preferences.
An initially flat desktop is captured without publishing. Missing originals fail
before writes. Reopening a visible app retains its baseline. Native tests cover
navigation, source/mode controls, optional guides, keyboard/geometry/startup and
exact restoration. See [spec](../specs/colors-welcome-performance.md).

Welcome opens centered and floating at up to1020×760 logical pixels, like
Settings and Colors. Its hero scales with available height, up to320px. Its live preview adapts to the
available space without painting outside its frame. The read-only cache
prepares every selected demo scene in both modes and all styles once, skips current
entries, and verifies unchanged immutable image copies by file identity after
full checksum validation. Changed/missing files still require validation/repair.

The same publisher streams each validated presentation after its atomic file
write, so the shell need not wait for filesystem delivery or companion generation.
Publication sequence numbers reject delayed older reads; matching image readiness
still gates new wallpapers. Welcome holds only four full-size still previews while
active, then releases them. Warm-up also prepares demo login backgrounds, avoiding
first-click image conversion. No idle animation, polling or second publisher.

Clicked styles/modes and scene rings acknowledge the request immediately while
the actual palette remains publication-owned. Pending highlights settle to the
committed selection or return to it on failure; previews show committed colors.

Super+M uses the ordinary Hyprland maximized toggle for every app; Super+T
toggles floating when desired. There is no special Nacre size state.
Super+S is the sole managed Settings shortcut. Welcome uses380px wheel steps
with110ms easing, 1.5× touchpad pixels and no added release momentum;
scrollbar dragging and page navigation stop prior motion. App descriptions wrap
and their Open button moves below the text on narrower windows.

Four existing local paths can be selected privately with
`welcome.py set-demo-wallpapers '["/absolute/path", ...]'`. These are stored in
0600 `~/.config/nacre/welcome.json`; personal images never enter the repository.
Unavailable choices fall back to the credited bundled collection. Video scenes
use cached posters in the cards and preloader. Both modes and all styles are
prepared read-only before use. Warm-up repairs missing branding rasters even when palette JSON is
already cached, since these caches have separate lifetimes. The UI has no Undo button; the bounded internal
opening snapshot remains available for verification and recovery.

Palette transports stay ready inside the shell: two serial request endpoints
reuse Python/module initialization, sleep on stdin between actions and are
recreated with the renderer. The existing preference/selection queue and shared
publication lock retain write ownership; helper CLI commands still work.

Personal cards omit collection captions; licensed bundled scenes retain attribution.
The preview height shares a finite viewport budget with cards and controls, while
small windows remain scrollable. Enlarging the window grows the hero and preview;
standard compositor maximize/restore retains the original floating geometry.
