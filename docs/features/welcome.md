# Nacre Welcome tour

Run `nacre-welcome` or open Welcome in the launcher. Five fixed-size pages use
Back/Next and clickable progress dots, with Enter to continue and Escape to close:

1. Welcome: logo and “Mother-of-pearl. Colors shaped by your wallpaper.”
2. Your colors: four small credited scenes, all eight color styles, dark/light
   icons and a live desktop/role strip. Choosing changes the real desktop through
   its existing publisher. Undo appears after changes and restores the opening
   wallpaper/palette; Open Colors and More wallpapers are the secondary actions.
3. Getting around: scrollable shortcut groups read live from described Hyprland binds.
   Alternative keys share a flexible-height row. Missing bindings are not guessed.
4. Apps: Settings/Colors plus optional AI/Brain with honest setup guides.
5. Ready: centered selection recap, Help/Maintenance and Start using Nacre.

The launcher can reopen the same tour. `nacre-welcome colors`, `shortcuts`, `apps`,
`ready` or `help` jumps directly to a section; legacy `home` starts Welcome.
Automatic login startup happens once per installation. The locked claim owner
records `firstRunShown` only after successful activation; failed activation releases
the claim and can retry. Finishing a manual tour also suppresses automatic startup.
Legacy `showAtLogin: false` remains an opt-out, and manual launcher opens always work.
Closing/skipping does not auto-install anything or reset chosen colors. Existing
snapshot/publisher error protection and original animated-source restoration stay.
Rotation pauses throughout an active tour. Panels remain normal captionless windows.
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

Welcome starts at no more than 920×680 logical pixels. Its compact live preview
fits its own contents rather than cropping a larger desktop. The read-only cache
prepares every bundled scene in both modes and all styles once, skips current
entries, and verifies unchanged immutable image copies by file identity after
full checksum validation. Changed/missing files still require validation/repair.

The same publisher streams each validated presentation after its atomic file
write, so the shell need not wait for filesystem delivery or companion generation.
Publication sequence numbers reject delayed older reads; matching image readiness
still gates new wallpapers. Welcome holds only four full-size still previews while
active, then releases them. Warm-up also prepares demo login backgrounds, avoiding
first-click image conversion. No idle animation, polling or second publisher.
