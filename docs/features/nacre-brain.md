# Nacre Brain

Launch **Nacre Brain** from the app launcher, press Super+B, or run `nacre-brain`.
The shell mark has a small two-tone brain beneath its right overhang. Its two
lobes use primary and secondary colors, with contrasting folds. The launcher
icon and web header follow the palette; no idle animation or polling is added.

`nacre-brain search WORDS`, `note`, `path` and the existing vault commands retain
their behavior. `nacre-brain-maintain` manages checks/backups and
`nacre-brain-sync` performs the existing three-way private sync. The knowledge
service is `nacre-brain.service`; sync/check timers use the same prefix.

Canonical paths:

- Vault: `~/Documents/Nacre-Brain`
- Runtime code: `~/.local/share/nacre/brain`
- Private state and browser authentication: `~/.local/state/nacre/brain`
- Dedicated browser profile: `~/.local/share/nacre/brain-browser`
- Optional local semantic model: `~/.local/share/nacre/brain-model`
- Sync configuration: `~/.config/nacre/brain-sync.json`

An explicit `NACRE_BRAIN` setting selects another vault. `NACRE_BRAIN_DIR`
can select the browser/index vault. Remote sync hosts need the canonical
`nacre-brain-sync` command. Keyring references use
`secret-service://nacre-brain/NAME`.

The service stops briefly for a code update; the browser profile and other
assistant workers stay running. Browser authentication remains private and uses
the `nacre_brain` cookie. No passwords, notes or browser data enter Git or desktop
release snapshots. Existing local aliases are host maintenance data rather than
fresh-install behavior. Inspect and deploy with the usual checks and
`./install.sh` plan/apply. See [maintenance](../maintenance.md).
