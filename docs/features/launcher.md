# Universal launcher

Super+A opens Nacre's main desktop menu. Home keeps alphabetical favorites and
recent destinations; All apps is a five-row icon grid. Application categories are
replaced by Actions, Style, Setup, Software, Health, Learn and Power.

Search from Home or All apps finds installed apps and commands at any depth.
Inside a section, search filters that section. Results show a breadcrumb and live
state. The detail pane explains the selected item, previews wallpapers/fonts and
provides secondary actions. Smaller outputs collapse the pane and adapt the grid
without losing its five rows.

Typing selects the best available result; blank browsing selects nothing until
arrow navigation. Enter opens or runs the selected item. Right enters a group or
opens its actions; Tab opens item actions when selected. Backspace with an empty
query goes back. Escape closes actions/confirmation first, then the launcher.
Ctrl+D and the favorite marker toggle favorites. Right-click offers app hiding,
known package removal and item actions. Saved older `nacre-action:` favorites
remain compatible. Recent history stores destination IDs, not questions or searches.

## Search scopes

| Prefix | Purpose |
| --- | --- |
| `>` | Desktop commands |
| `=` | Bounded arithmetic; Enter copies the result |
| `#` | Private Nacre Brain search |
| `?` | Explicit Nacre AI question |
| `/` | Show scope help |

Unmatched normal text never silently becomes an AI request. The assistant action
protects active work and unsent drafts. Arithmetic accepts the existing operators,
parentheses, constants and whitelisted functions; it never evaluates JavaScript or
shell source. Ordinary blank search does not activate an invisible first item.

## What lives here

Actions contains capture, clipboard, emoji, windows, reminders, assistant/knowledge
destinations and live toggles. Optional OCR, QR and recording tools show their
availability and a package setup action. Captures use existing grim/slurp tools;
recordings and reminders use explicitly owned user units. Canceling a region
selection leaves the clipboard intact. Stay awake inhibits automatic idle behavior
until disabled or logout; it does not replace session power management.

Style reuses wallpaper caches and Orient's publisher for wallpaper, personality,
background tint, brightness mode and accent selection. Interface fonts use the
existing validated desktop preference owner; other applications retain their own
font settings. Setup links to current Settings pages and private configuration.
Software has 28 curated choices, official/community package search, installed
packages and web-app creation. Package managers retain interactive confirmation
and authentication; paru uses the existing `--skipreview` preference. Nothing is
installed merely by browsing. Generated web apps contain a fixed launcher and a
random identifier rather than the entered URL in their Exec command.

Health uses the existing update/check/recovery owners. Rollback opens the review
page rather than blindly applying a release. Learn shows current keybindings,
Welcome and documentation. Power keeps lock/session ownership and requires an
explicit confirmation for session-closing operations. CLI routes only navigate;
opening a power leaf never executes it.

## Routes and customization

```sh
nacre-menu
nacre-menu actions.capture
nacre-menu style.personality
nacre-menu setup.displays
nacre-shell menu software.packages
```

The independent catalog is `nacre/shell-tools/launcher-menu.json`. Override fields
or add groups/actions in `~/.config/nacre/launcher-menu.json`:

```json
{"version":1,"entries":[
  {"id":"actions.terminal","label":"My terminal"},
  {"id":"actions.my-tool","kind":"action","label":"My tool",
   "icon":"terminal","operation":"command","arguments":["my-tool","--option"]}
]}
```

A matching ID overrides its declared fields. Hidden groups hide their descendants.
Invalid extensions preserve built-ins and show an error. Commands are explicit
argument arrays from this trusted local file; typed searches are never commands.
Apps cannot capture menu routes through keywords. Existing favorites/all/hidden/
actions category aliases remain; removed app categories lead to All apps.

Package/font/capability discovery is cached and refreshed on opening; native device
and preference state remains reactive. Normal search is in-memory. Package and
Brain searches are scoped, coalesced and reject obsolete results.

## Shared selectors

```sh
printf 'First\tone\nSecond\ttwo\n' | nacre-menu pick --title 'Choose a value'
nacre-menu input --title 'Name' --initial 'Example'
```

Plain selector rows are `label`, `label<TAB>value` or
`label<TAB>value<TAB>description`. `--json` accepts an array of objects with label,
value, description, icon and disabled fields. Selection returns only the value;
Escape/cancel exits nonzero. Input returns the entered text. Private generated
sessions use bounded files and a single-client lock; callers cannot select arbitrary
output paths. A request refuses to replace an open user drawer. There is no secret
input mode; native authentication remains with the existing OS/application owners.

Research informed capability/routing choices through
[Omarchy's official menu documentation](https://github.com/basecamp/omarchy/blob/quattro/docs/menu.md)
and public menu data. Its implementation bodies/catalog were not transplanted.
Nacre keeps its own QML, operations, palette language and brand assets.
