# Pearl dashboard

Move to the top handle to open the dashboard. The entire width of its header
keeps it open; Escape dismisses an explicitly opened menu. The frame still uses
one Wayland surface, so the header and moving handles retain their stacking and
input behavior. Settings remains a standalone app, opened with the header gear.

The five pages are **Dashboard, Weather, Media, System and Focus**. Click a tab,
scroll over the tab row, or use1–5 when a text field doesn't have focus. The
neutral pearl marks the current page and slides to the next selection. Reduce
motion disables that transition and decorative animation.

- Dashboard shows the wallpaper, date, local clock, current weather and live Orient
  swatches. Video/animated previews respect pause, battery and reduced motion.
  Next deliberately changes the wallpaper; Colors opens the existing color picker.
  The month calendar fills the left column; host details and three performance
  circles occupy the middle, and the player/spectrum occupy the right. The former
  Up next section has been replaced by that system summary.
- Weather includes current conditions,24hour temperature/rain chart,10day range
  bars and wind, UV, humidity, AQI and pressure. Its living sky uses Orient colors
  and actual day/conditions. Sky animation stops outside this page. The existing
  weather owner now fetches [Open-Meteo](https://open-meteo.com/en/docs), keeping
  cached/stale labels and legacy lock-screen fields. AQ failure doesn't discard
  the weather forecast. Location still follows Date and time settings.
- Media preserves player membership/capability and seek-owner guards. Cava draws
  a real32band spiral only while playing, page-visible and motion-enabled.
  [LRCLIB](https://lrclib.net/docs) provides optional line-timed lyrics. Album
  Orient colors are scoped to this page; they never recolor the desktop. Track
  details are private/cached and stale track responses are ignored. Missing
  lyrics/artwork/audio analyzers have honest empty states. The output button opens
  existing guarded audio controls.
- System uses chamber gauges, a visible-only network graph, disk use and current
  user's top12processes by memory. End requires a second press within5seconds and
  revalidates the process start identity via Linux pidfd before SIGTERM. It never
  terminates the dashboard's ancestors. Missing GPU sensors show unavailable.
  Update invokes the existing update terminal with `paru -Syu --skipreview`.
- Focus offers15/25/50minute sessions with pause/resume/stop. A wall-clock deadline
  persists across shell restarts and includes suspended time. A small pearl fill
  on the top handle shows progress. DND returns to its prior setting only when
  the timer still owns the change; manual DND changes relinquish ownership.
  Finishing creates one ordinary notification. Optional Brain capture saves a
  private inbox note on Enter; recent notes/tasks can be filtered/opened. Brain
  isn't required for the timer. Tasks are drawn from recent notes, not a claimed
  complete task index.

## Personalize

The tune button opens dashboard options. Show/hide/reorder pages (at least one
stays enabled), choose lyrics/album colors, and optionally set home timezone/city
and an absolute local `.ics` export path. Home time appears when its UTC offset
differs from the current local time. A confirmed timezone is used as the fallback
home zone; we don't invent a home city. ICS reads are bounded; recurring events
require an expanded export. Google/CalDAV authentication/sync remains with the
user's calendar app. This release does not add cloud-account integration or Pins.

Preferences live in `~/.config/nacre/dashboard.json`; focus deadlines in
`~/.local/state/nacre/dashboard-focus.json`, with atomic0600 writes. Track
cache under `~/.cache/nacre/dashboard-media` retains80entries. No artwork,
lyrics, calendars, notes or private state are committed to the repository.

## Performance and checks

The service performs no per-second Python calls for focus. Resource/network
sampling and process snapshots are visible-only; the process/disk snapshot is
once per10seconds on System, network reads use FileView every2seconds. Dashboard
context reads are once per minute while open; Brain reads are bounded and only
requested for Focus/capture. Current weather retains its30minute refresh. Lyrics
and album extraction happen per track/options change, using a private cache.
Cava is an optional system dependency and exits when the Media view closes.
The Open-Meteo service preserves current lock clients rather than adding another
weather daemon. No idle visual loop runs in closed panels.

Native assembly tests cover all five tabs, hidden-page fallback, transition
teardown, viewport limits and reduced motion. Provider tests cover validated
preferences, private writes, focus deadlines/ownership, bounded calendar import,
forecast normalization/stale cache, lyrics timestamps/cache and stale PID guards.
Review real Wayland screenshots and hover/Escape/header retention after deploy.

## Dashboard home layout

The first tab is labelled Dashboard; its private `today` identifier preserves
existing preferences. The wallpaper banner has Wallpapers and Colors side by side above a fixed-width
previous/pause/next control matching the top row’s width. Static wallpapers show a picture icon in the center with a Static wallpaper
tooltip; it is an indicator, and clicking it does not change playback. The arrows
stay in the same place. Pause stops video/GIF motion through the existing
persisted playback preference; the separate scheduled rotation setting is unchanged.
Previous retraces up to100successful visits in this shell session, including shuffle.
With no history, it uses the previous catalogue entry in the selected rotation pool. Next calls the current `advanceRotation(true)` interface, so it
works with automatic rotation off while respecting an in-progress change.

Below the banner, a shorter calendar fills the left column. The middle column
restores the Nacre logo, username, OS, compositor, uptime and updates above three
compact CPU/memory/storage circles. Clicking updates opens the existing update
terminal. The player fills the right column down to the same bottom edge. Its
album progress ring is surrounded by a real32band audio halo, primary near the
cover through secondary to tertiary at the outer edge. No empty spectrum strip
remains beneath it. Paused, silent, hidden and reduced-motion states hide the
halo. One existing Cava process serves Dashboard and Media; album/lyrics work
remains Media-only. All pages fit the original650logical-pixel frame when space
permits; narrow views stack the blocks and scroll.

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

Wallpaper history captures the outgoing path when the selection transaction starts.
The last-poster file can update before the worker response; reading current state
at completion can otherwise remember a cache image instead of the real wallpaper.
A native regression covers that order, and real Next/Previous checks verify the
original wallpaper is restored.

At narrow widths, the wallpaper buttons stay inside the banner. The pearl strip
shows the three accents below440px and yields space to the controls below360px;
Colors remains available. Native layout checks cover580px,360px and240px views.
