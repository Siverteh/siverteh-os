# Dashboard home refinement

User-directed refinement of the first pearl dashboard page,2026-10-11.
Keep the wallpaper hero. The visible page name is Dashboard (the private `today`
id stays compatible with existing tab preferences).

Below the hero, align three columns on one bottom edge: a month calendar spanning
all remaining height; restored logo/username/OS/compositor/uptime/update details
above three compact CPU, memory and storage circles; compact current-player card
above an upward real-audio spectrum. The spectrum runs bottom-primary through
secondary to top-tertiary. No synthetic beats. Paused/unavailable audio is quiet.
Use the existing single shared Cava owner, now visible on Dashboard or Media;
lyrics and album extraction remain restricted to Media. Preserve capability
checks, visible-only resources, reduced motion and closed-panel input release.

The first page may grow to736logical pixels to fit a useful calendar and cover;
other pages keep their current size. Narrow views stack the same blocks and use
FastScroll. Ring/spectrum changes animate finitely, never idle-loop.

Native proof: real Qt lower-section geometry shares one bottom baseline; compact
media controls fit bounds, missing readings remain unknown, spectrum changes
height from real supplied samples and respects inactivity/reduced motion. Full
checks, Hyprland verification, plan/apply, source/live navigation and CI follow.

## Follow-up refinement

User approved the OS card, then requested a shorter calendar, smaller performance
circles and a full-height player without an empty strip below. The frame returns
to650pixels. Use an owned radial audio halo outside the cover's seek ring, hidden
for pause/silence/reduced motion. Preserve guarded transport/clock behavior.
Next was wired to an absent rotate method; call advanceRotation(true) and prove
actual button behavior. Add a wide Wallpapers button above Next/Colors.

## Shared system card and responsive wallpaper preview

The OS details and three performance circles share one continuous raised surface.
Kernel version adds a practical sixth row; uptime opens System and updates starts
the existing update terminal. The media card omits the timer beneath transport;
its seek ring flows primary through secondary to tertiary.

Video previews start each newly loaded source, including video-to-video Next
changes while Dashboard remains open. Closing/pausing still releases playback.
Busy buttons release focus; a separate pointer hover handler avoids MouseArea's
stale hover after disable/re-enable, while keyboard focus remains visible. Native
tests cover two actual generated video files, busy/hover/focus states, card
baselines and both system actions.

## Wallpaper transport refinement

Use Wallpapers and Colors side by side above a pill of the same total width, with three equal slots:
chevron-left, pause/play, chevron-right. Static images show an informative picture glyph in the center; never
move arrows when changing media type. Both rows share left/right edges; the middle
slot remains reserved on static images and has no playback action. Give controls themed tooltips and accessible
labels. Pause uses the single existing wallpaper preference owner, not a new player
or timer. Previous follows a bounded100entry successful-visit history, with previous
catalogue entry as the initial fallback. Do not consume history on a failed change.
Native tests exercise shuffled/sequential history, busy guards, pause persistence
command, noninteractive static indicator, source restart and fixed positions across static/dynamic changes.

Wallpaper history captures the outgoing path when the selection transaction starts.
The last-poster file can update before the worker response; reading current state
at completion can otherwise remember a cache image instead of the real wallpaper.
A native regression covers that order, and real Next/Previous checks verify the
original wallpaper is restored.

The wallpaper action group uses equal-width Wallpapers/Colors buttons above a
matching transport row. Softer rectangular corners and restrained palette-tinted
surfaces keep it legible over moving wallpaper; the center glyph has a small tint
badge. Static glyphs retain full contrast and an accessible indicator label.
Existing finite hover/focus feedback and reduced-motion guards remain; no new
idle animation, wallpaper worker or preference owner is introduced.

At narrow widths, the wallpaper buttons stay inside the banner. The pearl strip
shows the three accents below440px and yields space to the controls below360px;
Colors remains available. Native layout checks cover580px,360px and240px views.
