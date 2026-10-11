# Completed source audit

The rewrite audit is archived at the annotated Git tag
`provenance-audit-complete-2026-10-11`, commit
`2f6298ab451b88d116adc8fd97802ec7c4dfc628`. All 905 source/artifact reviews
were resolved; the registry metadata was anchored independently at that commit.

This is a historical conclusion about those exact bytes, not an authorship
certificate for future changes. The snapshot retains the original registry,
audit tool and its tests. To reproduce it, check out that tag in an isolated
worktree and run:

```sh
python3 tools/provenance.py --complete --metadata-revision 2f6298ab451b88d116adc8fd97802ec7c4dfc628
```

Future contributions use formatting, linting, regression tests and normal code
review. They do not update a per-file hash registry. `PROVENANCE.md`, area audit
reports, LICENSE and NOTICE files remain attribution and historical evidence.
New third-party source or assets still require their applicable license/notice.
See [final comparison](FINAL-COMPARISON.md) for the completed runtime mapping.
