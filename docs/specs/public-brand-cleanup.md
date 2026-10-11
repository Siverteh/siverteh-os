# Public product naming

Nacre is the maintained desktop, AI controller and Brain identity. Active code,
configuration, helpers, agent guidance, skills and fresh-install defaults must
use canonical Nacre names. This change is naming and retirement work, not a
claim to have rewritten the implementation again.

- Promote the actual AI controller/helpers to `nacre-ai*` rather than forwarding.
- Store AI data/config/state in their respective `nacre/ai` roots.
- Rename terminal classes, MCP servers, sidebar service/socket, display recovery,
  app scopes, startup locks and drag keys as matching producer/consumer pairs.
- Remove obsolete namespace migration modules and source compatibility wrappers.
- Remove legacy font lookup while retaining checksum, ownership, drift and rollback.
- Use neutral personal capture context rather than a hard-coded individual's name.
- Keep original license/NOTICE attribution and dated provenance evidence accurate.
- Keep private aliases/journals outside Git; preserve workers and authentication.

Validation covers the complete repository check, fresh-home controller installation,
provider/account/history tests, service/window contracts, font rollback and live
compositor/shell/Brain verification. Physical login/suspend and interactive account
sign-in are separate acceptance checks, not implied by automated test success.

Historical audit paths and comparison records describe the revisions they audited.
The provenance registry maps renamed current files to those existing evidence
records, retaining their original statements and adding this change's review.
