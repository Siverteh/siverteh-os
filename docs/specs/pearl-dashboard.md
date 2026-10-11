# Nacre pearl dashboard

Purpose: replace the top menu's generic overview with Today, Weather, Media,
System and Focus. Preserve the single frame surface, hover-retention span,
fullscreen rules, moving handles, Escape and logical input release. Settings
remains its existing standalone window, available through a quiet header action.

## Design

Use the live Orient body/ink/primary/secondary/tertiary tokens, IBM Plex Sans and
existing Nacre icons. Pearl knobs are neutral highlights with dark contrast.
One hero per page has a faint orient rim; supporting areas use quiet shading,
not outlined boxes. The horizontal tab neck has icons plus labels and a sliding
pearl. Width is stable across tabs, constrained by viewport. Pages cross-slide
in 180ms; opening uses the existing 360ms frame animation. No idle loop.
Reduced motion completes transitions immediately. FastScroll on every long view.

Today: dim wallpaper/video hero, readable clock/date/current weather, live palette
pearls, explicit next-wallpaper and Colors actions. Month calendar, optional local
ICS upcoming events, current media only when available, small resource summary.
Home time only when a configured/confirmed home timezone differs from local.

Weather: same existing weather owner, extended Open-Meteo HTTPS snapshot with
current conditions, 24 hours, 10 days, sunrise/sunset, wind/humidity/UV/pressure
and optional AQ. Preserve legacy lock consumers and truthful stale/failure state.
Sky follows actual day/conditions, tinted by Orient. Animation only visible and
motion enabled. Forecast charts don't imply unavailable readings are zero.

Media: existing MPRIS membership/capability guards and captured seek owner.
Optional Cava spiral uses real spectrum, only visible+playing+motion-enabled.
LRCLIB line-synced lyrics fetched/cache on track changes, stale responses ignored.
Optional album Orient palette affects this page only, never global publication.
Output-device action opens existing audio controls; no device writes on viewing.

System: chamber gauges with missing-sensor states, visible-only network history,
disks/top processes snapshot. End action revalidates PID/start identity and never
acts on stale selection. Updates keep the established paru --skipreview path.

Focus: optional existing private Brain index/read/capture; no vault in Git.
Persistent wall-clock deadline, pause/resume/reset, default25minutes.
Focus temporarily enables DND and restores its prior value only if still owned;
manual DND changes relinquish ownership. A small top-handle fill shows progress.
No process per tick; suspended time counts toward deadline. Finishing emits one
real notification. No AI permission changes.

Customization: hide/reorder tabs while retaining at least one, enable lyrics and
album palette, choose home zone/city and optional local ICS file. Private validated
preferences with atomic0600 writes. Calendar recurrence reports limitations;
no OAuth/CalDAV account setup or fake events. Numeric keys1–5 use visible order;
wheel over tabs moves one step per gesture. Updates source/metadata docs retained.

## Proof

Native Qt assembly/tab order, keyboard/wheel, close/unload, reduced-motion tests;
providers' cached/stale forecasts, untrusted input, calendar bounds, focus
ownership/deadline and guarded PID termination tests. Real dashboard screenshots
all five pages, real hover/Escape across full top span, single-surface stacking and
no hidden provider polling/visualizer; full tools/check, Hyprland verify, reviewed
plan/apply, exact source/live IPC and CI before publication.
