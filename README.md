# Siverteh OS

My personal edition of [Nacre](https://github.com/nacre-desktop/nacre), using the
independent [Orient](https://github.com/nacre-desktop/orient) color engine.

This repository contains my workspace labels/icons, app routing, startup choices,
explicit AI permission preference and a tested upstream revision. Desktop/app code
lives in Nacre; palette code lives in Orient. There is one implementation of each.
My accounts, conversations, memory vault, wallpaper collection and host overrides
stay on my devices, outside Git. The repository does not distribute my memories.

```sh
./install.sh                         # inspect the personal deployment plan
./install.sh --prepare /tmp/personal # prepare an empty-home installation
./install.sh --apply                 # managed personal deployment
./install.sh --profile default --prepare /tmp/general
python3 tools/upstream.py status
```

The wrapper retrieves an immutable Nacre commit with its pinned Orient submodule.
Cached checkouts are read-only consumers; modified caches are refused, not reset.
Installation uses upstream's validated managed-copy/rollback workflow. A default
profile preview does not replace my running desktop. Test a full generic login in
a separate user/accelerated VM; simultaneous shared-user shell owners are unsupported.

Generic fixes/features are developed upstream first. After upstream tests/CI:

```sh
python3 tools/upstream.py pin v0.1.0-dev.1
python3 tools/check.py
```

Review and commit the new pin, then deploy it. Tag/branch inputs are resolved to
an exact commit; installations never silently follow a floating branch. Initial
versions are development previews in the0.x series, not a1.0 public release.

Your existing accounts, memories and wallpapers remain in their current local
locations. This repository contains configuration and an upstream pin, not those
private data. Profile/installer source is GPL-3.0-only; see LICENSE.
