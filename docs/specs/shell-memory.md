# Shell image memory and retained state

Scope: decoded still images held by Colors/Welcome and the desktop's wallpaper
transition slots. Keep original dynamic media, decoder selection, robust playback
buffers, frame rate, image quality, palette caches and explicit publication owners.

## Contracts

- `NacreImage` bounds decoded pixels to its physical display size by default.
  An explicit `requestedSize` retains existing preview dimensions; `loadOriginal`
  remains available. Local paths are encoded, including percent/hash characters.
- Image requests run asynchronously. A changed path is scheduled at the next
  event turn; resize requests retain the existing 50ms coalescing behavior.
- Closed app and hidden preview images keep their pixels for five seconds, so
  immediate reopening/tab changes reuse them. Afterward, clear the image source,
  while retaining its requested path and all non-image UI/draft state. Reopening
  requests the same bounded image. Minimized Colors remains warm: closure is
  determined by the app's logical visibility, not workspace/focus alone.
- Desktop presentation retains three slots during an asynchronous transition:
  the incoming image, opaque outgoing image, and an optional newest queued request.
  When a transition settles, retain the current and immediately previous posters
  for reverse navigation. Release older slots unless they hold the newest request.
  Colors and image readiness still activate through `NacrePresentation` together.
- Do not clear active images, remove prefetching, disable animation, reduce source
  quality, periodically force garbage collection or tune the global allocator.

## Allocator policy

The shell launcher supplies jemalloc defaults for asynchronous background purging
with two-second dirty/muzzy decay. It does not change arenas, live buffers,
compressed media, caching ownership or rendering quality. Existing `MALLOC_CONF`
options follow the defaults so the allocator preserves caller precedence. On a
renderer using another allocator, these jemalloc options have no effect. No
system-wide environment file is changed.

Matched isolated 4K decoder tests retained about192MiB PSS with default allocation
versus123MiB with background decay, with essentially equal delivered frame counts.
Actual desktop memory and interaction timings require the same pinned workload.
Graphics-scene and glibc trim experiments did not show a useful actual-desktop
saving and are excluded. The native module/build dependency was removed.

Reference: [jemalloc background threads and decay](https://jemalloc.net/jemalloc.3.html).

## Verification

Native image tests check grace-period reopening, release of decoded sources,
initially hidden images, encoded filenames and stable requested decode dimensions.
Production scene tests check queued three-image switching, opaque outgoing pixels,
last-image reuse and bounded retained slots after settling. Existing Colors,
Welcome, foundation, playback/session and source/deployment gates remain required.

Compare memory after the same workload and session initialization. Record PSS,
which divides shared memory between processes, alongside RSS. Neither number is
GPU-only memory or the total operating-system footprint. Keep private wallpaper
paths and logs outside Git. A fresh-session improvement must not be attributed
to source changes unless the unmodified fresh baseline was also measured.

The 2026-10-11 isolated allocator experiment did not establish a useful benefit
from fixed large-allocation/trim thresholds, and no allocator flag is shipped.
Decoder experiments likewise retain automatic selection rather than forcing a
backend. The measured live outcome belongs in the private dated checkpoint.

References: [Qt image sizing/cache guidance](https://doc.qt.io/qt-6/qml-qtquick-image.html),
[glibc allocation tunables](https://sourceware.org/glibc/manual/latest/html_node/Memory-Allocation-Tunables.html),
and the preceding [responsiveness audit](../audits/desktop-responsiveness.md).
