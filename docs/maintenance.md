# Maintaining Nacre

Use an isolated worktree and keep host/account state outside Git. Read the
component ownership map in [architecture](architecture.md) before changing a
provider. Preview APIs stay read-only; palette publication has one owner.

## Checks

Install the pinned development tools (Ruff 0.16.10 and Qt's qmlformat), then run:

```sh
npm ci --ignore-scripts --no-audit --no-fund
python3 tools/check.py
```

The runner discovers Python scripts including extensionless `bin/` commands,
checks Ruff formatting/default lint/bugbear/broad catches, parses and formats
QML/native JS, runs the unit/native Qt suites, and validates the browser JS.
Prettier is a development dependency only. Optional tools are reported locally;
CI installs them and requires browser formatting. Fixtures use temporary homes
and fake device/service owners rather than changing the user's preferences.

Native JavaScript follows `qmlformat`; browser JavaScript follows the locked
Prettier version (`npm run format:browser`). The engine inherits the root lint
policy while retaining its 120-column Python formatter convention.

Document any broad exception boundary at the catch. Routine filesystem, JSON,
network and subprocess failures should use explicit types. Transaction rollback
must run even for an unexpected error and re-raise it. Optional backend boundaries
may translate failures into their protocol's structured error. Preserve the
original exception cause when converting an internal error, or explicitly suppress
it when a CLI has already printed its user-facing error.

## Developer utilities

```sh
PYTHONPATH=nacre/shell-cli/src python3 tools/generate-palettes.py
python3 tools/fetch-wallpapers.py
```

The generator also accepts `--output-dir` for isolated output. The fetcher writes
the curated trial collection to the user's Pictures directory; it is not an
installed runtime service. Source changes update Orient's fingerprint, so regenerate
the checked-in boot seed even when a behavior-preserving refactor keeps all colors
identical. Gallery/regression tests verify the role policy separately.

## Review and history

The rewrite's exact-source audit is complete and frozen at
[`provenance-audit-complete-2026-10-11`](https://github.com/Siverteh/siverteh-os/tree/provenance-audit-complete-2026-10-11).
The tagged tree contains its registry, checker and tests. Future changes do not
maintain a file-hash inventory. Preserve LICENSE, NOTICE, PROVENANCE and applicable
asset/dependency credits; the historical audit is not a license exemption.

Prefer small helpers at existing behavior boundaries. Keep public entry points
and error/transaction order intact. For substantial refactors, compare representative
old/new outputs in addition to tests, and measure any changed hot path. Avoid
rewriting an entire UI/state machine merely to make a file shorter. Current large
menu/browser views can be extracted incrementally when their behavior next changes.

Delete old remote branches only after fetching current heads and checking ancestry
against main plus open pull requests. Use deletion leases to reject concurrent
head changes. Preserve unmerged branches and record names/hashes for recovery.
