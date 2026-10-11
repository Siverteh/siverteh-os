# Nacre locations and naming

Nacre commands, services and fresh-install paths use the public product name.
The Linux account name and distribution identity are independent of that name.
Historical provenance, copyright and NOTICE records retain their original names.

| Component | Canonical path |
| --- | --- |
| Preferences and private Lua overrides | `~/.config/nacre` |
| Desktop state | `~/.local/state/nacre` |
| Desktop caches | `~/.cache/nacre` |
| Desktop source | `~/.local/share/nacre/shell` |
| Palette environment | `~/.local/share/nacre/palette-runtime` |
| Branding | `~/.local/share/nacre/branding` |
| Maintenance controller | `~/.local/share/nacre/control` |
| AI accounts, chats, tools and worktrees | `~/.local/share/nacre/ai` |
| AI registry and settings | `~/.config/nacre/ai` |
| AI logs, usage and title state | `~/.local/state/nacre/ai` |

`nacre-ai` is the actual controller; helper commands use the same prefix.
The terminal window classes are `nacre-ai-dashboard` and `nacre-ai-task`.
The persistent sidebar backend is `nacre-sidebar-ai.service`. Workflow and
sidebar MCP servers use `nacre_workflow` and `nacre_sidebar` respectively.

The source no longer installs legacy commands, services or path migrations.
A previously installed host can retain private compatibility aliases for its
existing workers and rollback data. These aliases are outside Git and are not
part of a fresh installation. Never copy provider authentication between profiles
or hosts to perform a name migration. Keep conversations, private notes, browser
profiles and credentials outside desktop release snapshots.

Root-owned appearance uses `/usr/share/sddm/themes/nacre`,
`/var/lib/nacre/login`, `/etc/nacre` and `/var/lib/nacre`.
The current timezone installer owns `nacre-timezone` integration; the login
installer owns appearance only and never restarts the display manager.
See [maintenance](../maintenance.md) and [Brain](nacre-brain.md).
