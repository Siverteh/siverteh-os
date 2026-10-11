# Nacre universal launcher

2026-10-11. User-authorized expansion of Super+A into the desktop's main entry
point. This supersedes application category browsing in the earlier launcher
spec. Keep the five-row app grid, alphabetical mixed favorites, selection only
after typing or arrow navigation, the current shortcut combinations, private
preferences and the existing shell/palette/AI/Brain/settings owners.

## Experience

Home (favorites and recent destinations), All apps, Actions, Style, Setup,
Software, Health, Learn and Power form a permanent navigation rail. Commands use
compact descriptive rows; apps use a five-row icon grid. A right-hand detail pane
shows the selected item's purpose, state, secondary actions and wallpaper previews.
Small screens collapse details rather than shrinking text into illegibility.
Selection uses readable surface ink, a quiet pearl tint and an Orient-colored edge.

Search spans apps and every descendant menu entry. Results carry a breadcrumb.
Explicit scopes are > actions, = arithmetic, # private Brain search, ? Nacre AI,
and / scope help. Normal unmatched text never silently starts an AI request.
Enter activates the visibly selected result; Right enters a group or opens item
actions; Tab opens item actions when selected, otherwise moves between navigation
and search. Backspace with an empty query and Left return to the parent. Escape
first dismisses item actions/confirmation, then closes the launcher. Apps support
open, favorite, hide/show and package removal when ownership is known. Menu items
can be favorited. Store stable IDs, never search text as executable commands.

## Catalog and routing

Author an independent typed JSON catalog and model. Dotted IDs describe routes;
kind and operation are explicit. A private extension can add entries or override
fields and hide entries. Validate IDs, operations, argument types, parents, links
and cycles. Invalid extensions retain the shipped catalog with a visible error.
Installed apps and provider rows cannot claim built-in routes through keywords.
All native shortcut, CLI and internal links share route resolution. Opening a
leaf route selects it; it does not execute it. Existing appBrowser category calls
retain favorites/all/hidden/actions aliases; retired app categories resolve to Apps.

Runtime providers reuse desktop entries, wallpaper caches, native network/audio/
Bluetooth state, window state, shortcut discovery and private Brain/clipboard
helpers. Enumerate packages/fonts/capabilities on demand and cache answers; never
fork a process per row or keystroke. Cancel/coalesce asynchronous query work and
ignore stale results. Disabled optional features explain their missing dependency
and offer software setup. Show optional AI/Brain destinations even if unavailable.

## Reach

Actions expose capture, color picking, recording/OCR/QR when tools are available,
clipboard, emoji, arithmetic, windows, reminders, assistant/knowledge destinations
and live toggles. Style exposes wallpapers, Orient personalities, light/dark,
accent choices and interface fonts through existing preference/palette publishers.
Setup deep-links to every current Settings page and host configuration tools.
Software offers a modest curated catalog, package search/install/remove and web-app
creation. Package managers retain their own interactive review/authorization;
paru retains the user's --skipreview preference. Never install software during QA.
Health exposes existing update/check/recovery owners with meaningful summaries.
Learn exposes live bindings, Welcome and documentation. Power operations honor
session ownership; closing-session operations require an explicit confirmation.
Do not execute power, lock, suspend, install/remove, rollback or AI-send operations
in live verification.

## Shared selectors

Provide CLI pick and text-input modes using this same window. Requests and responses
live only in a private, bounded, generated session directory; caller JSON cannot
choose arbitrary output files or commands. Cancel exits nonzero. Concurrent requests
must not overwrite one another or an open user view. No secret-input mode or new
authentication/credential owner. App/network authentication retains native owners.

## Verification and origin

Use actual model/view/helper code with fake external services for hierarchy, global
ranking, alias isolation, malformed extension fallback, live state, favorites,
route opening, clipboard-safe cancellation, prompt lifetime, delayed results,
package argument handling and confirmation guards. Render several palettes/sizes;
inspect the live launcher, typing, navigation, focus, Escape and outside dismissal.
Run normal full/native/deployment/rollback gates, preserve preference/worker identity,
and require exact published CI. Keep this task in its own worktree.

Research: Omarchy's official docs/menu.md and public menu data at its default
quattro branch were consulted for capabilities and behavior. No Menu.qml,
MenuModel.js or inherited Caelestia/ML4W implementation was consulted or copied.
Implement Nacre's catalog/model independently; do not transplant its menu/catalog.
References: https://github.com/basecamp/omarchy/blob/quattro/docs/menu.md and
https://github.com/basecamp/omarchy/blob/quattro/default/omarchy/omarchy-menu.jsonc.
