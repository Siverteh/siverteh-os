# Maintainability cleanup — 2026-10-11

Baseline: `2f6298ab451b88d116adc8fd97802ec7c4dfc628`.

## Changes

- Removed 50 unused small QML components/compatibility forwarders. Removed the
  retired overview, performance and workspace pages plus their three exclusive
  card/ring dependencies. The current dashboard summary still uses calendar,
  host and media cards; its tests and shared fixtures remain.
- Moved the preset generator and trial collection fetcher into `tools/`. The
  generator has an explicit output directory and its reproducibility tests remain.
- Archived the completed 905-artifact rewrite review under annotated tag
  `provenance-audit-complete-2026-10-11`. Removed the live hash registry/checker
  and its CI gate. Preserved provenance reports, licenses, notices and credits.
- Enforced Python default lint, bugbear and broad-exception checks in the existing
  runner. Fixed imports, explicit re-exports, callback bindings, equal-length zip
  expectations and exception causes. Routine failure catches now name their
  types; rollback and optional backend boundaries explain their broad catches.
- Applied/enforced Qt formatting to native JavaScript and pinned development-only
  Prettier to browser JavaScript. No runtime formatter dependency was introduced.
- Split six large Python entry points at their existing stages, without changing
  their caller signatures or transaction/publication order. Brain graph node
  construction now indexes notes by ID instead of repeatedly scanning the list.
- Deleted 23 old remote branch heads verified as ancestors of main, using atomic
  deletion with exact-head leases. Preserved the two non-ancestor Codex branches.

## Behavior evidence

A source snapshot of the baseline and the candidate were run against identical
isolated inputs. All 96 gallery palettes (every style, both brightness modes),
312 generated theme files, four Brain discovery scenarios (including semantic
vectors/manual overrides/prior identity), and three lock-render pixel hashes
matched. The engine's source fingerprint differs intentionally; generated boot
metadata was refreshed. Private input/output artifacts remain outside Git.

The full local check passed 566 retained Python tests, native Qt UI validation,
Ruff, QML/native JavaScript formatting, browser syntax/formatting and palette CLI
smoke checks. Two additional decoder-safety regressions passed in the targeted
wallpaper/lock suites (31 tests). Candidate Hyprland configuration parsed correctly.
Old page tests and the historical provenance checker tests were removed with their
retired targets, rather than retained as misleading current-feature coverage.

The large menu/browser UI files remain suitable for incremental extraction when
those behaviors next change. This cleanup preserves their tested UI/state machine
rather than rewriting it solely to reduce file length.
