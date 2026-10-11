# Desktop responsiveness and maintenance audit

Reviewed: 2026-10-11. Scope: wallpaper/catalogue/presentation, Orient queries and
Colors, Settings requests/pages, Welcome reuse, launcher/action availability,
process lifetime, cache integrity, decoder transitions and native UI tests.
The tree inventory covered current Nacre files; detailed review concentrated on
these interactive paths. This is not a claim that every line or every physical
device action was exercised.

## Ownership and boundaries

Keep the existing palette publisher, presentation handshake, device helpers and
notification server. Previews remain read-only. Input acknowledgements are not
proof that a device applied a setting; generated state and helper success are
still authoritative. Expensive work stays outside the QML rendering thread.

The review follows [Qt's performance guidance](https://doc.qt.io/qt-6/qtquick-performance.html):
measure hot paths, avoid redundant bindings/work and use asynchronous requests.
Hardware changes, login/authentication, package removals and remote-account
migration are outside this pass. No palette algorithm, contrast policy, logo or
private user data is replaced.

## Changes and evidence

| Finding | Change | Proof |
| --- | --- | --- |
| Picker explicitly destroyed/paused the desktop decoder | Keep it alive while browsing that output; ignore covered-window pausing only for that output's open picker | Production scene tests retain manual, battery, lock and sleep guards; live motion position check |
| Catalogue refresh replaced equal media objects | Preview restart identity uses media path/poster/type instead of object identity; encoded URLs and loaded-media startup retained | Picker/native wrapper checks |
| Colors paid Python imports for every preview | One serial read-only helper while the app is open; stable sequence IDs reject stale replies; close reaps the helper | Real CLI stream and production request-owner tests |
| Cached Colors staging rebuilt unchanged output | Bounded staged response cache; source/favorite/request/engine identity, colour validation, corrupt-record repair and source-change check | Backend cache/no-publication tests |
| Discrete style controls had a fixed 90ms delay | Discrete changes start at the next event turn; fine-tuning is coalesced for60ms; successful no-op selections do no work, errors remain retryable | Owner generation/no-op tests and timing checks |
| Auto desktop mode could enter a dark/light-only preview API | Preview starts with the resolved active mode | Production owner auto/light test |
| Rapid settings clicks read stale saved values | Display the newest requested value immediately; revisioned acknowledgements and failure rollback; coalesce pending same-key writes across set-only segments | Native rapid-click/late-ack/error tests |
| Hidden Settings launched a state helper every minute | Refresh when opened and every3seconds while visible; retain native file watching | Real timer visibility test |
| Every theme click accumulated another publication | Merge pending values only within the same command class; selection and preferences use one serial transport | Queue and shared-transport tests |
| Colors Apply waited for filesystem delivery | Consume opt-in presentation packets through the existing ready-image activation; plain export/favorite results remain unchanged | Publisher/Colors checks and live Apply verification |
| Media commands remained enabled with no supported player | Disable unsupported actions with an explanatory reason | Launcher owner/native checks |

## Measurements

Warm preview calculations were about13ms in-process, while the original
per-request helper took about79ms. The original UI also had a90ms debounce.
The new persistent preview transport measured about6ms warm round-trip in the
reference workload; first helper startup still costs about53ms. These are helper
measurements, not a claim of a6ms complete screen repaint. Live click-to-ready
measurements and packet/image validation belong in the private dated checkpoint.

One 4K HEVC30fps workload raised renderer resident memory from roughly1.2GB to
1.78GB while the picker was open and retained about1.61GB after closing. A separate
matched decoder test retained roughly418MB with default allocation versus407MB
with two allocator arenas, with the same163frame callbacks. That small retained
memory difference did not justify shipping an allocator flag. Video buffers and
allocator retention remain a cost to monitor, not a proven leak.

[Qt playback options](https://doc.qt.io/qt-6/qplaybackoptions.html) distinguish
robust playback from reduced-buffer streaming with a greater chance of dropped
frames. Quality defaults remain. [glibc allocator tuning](https://sourceware.org/glibc/manual/latest/html_node/Memory-Allocation-Tunables.html)
was evaluated in an isolated process; no global or renderer tuning is applied.

## Maintenance rules

- Preserve explicit queue barriers: a preset/display action is not a coalescible
  setting write; picker layout preferences are not a palette/theme transaction.
- A cache hit must match source identity and engine/options. Missing, malformed
  or old records regenerate; cache cleanup must not become an idle polling job.
- A persistent helper owns one stream. Correlate replies with immutable sequence
  IDs; do not reuse mutable request fields as cancellation identities.
- A hidden app must not keep a preview computation alive. Keep drafts/UI state
  separately from helper processes and decoded resources.
- Preserve side-effect-free page loading and explicit Apply. Use fake device and
  application owners in broad button tests, then narrow live checks for safe paths.
- Keep tiny compatibility forwarders when existing consumers/tests use them.
  Remove a component only after tracing its imports and public behavior; fewer
  filenames alone is not evidence of less runtime work.
- Native timers, event watches and optional-tools discovery serve different
  purposes. Avoid replacing event delivery with frequent subprocess polling.
- Keep specs, normal code reviews and exact-revision CI alongside meaningful behavior
  checks. Formatting/parser success alone does not prove readiness or smoothness.

## Remaining limits

The native suite covers page loading, layout, ordinary controls, request owners,
error handling and safe command boundaries. It does not physically test every
Wi-Fi/Bluetooth/audio device, PAM unlock, multiple outputs or every external theme
consumer. 4K decoder memory, first-time uncached extraction and toolkit-specific
reload costs need representative-hardware profiling before more aggressive work.
