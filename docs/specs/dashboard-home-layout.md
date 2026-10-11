# Dashboard home refinement

User-directed refinement of the first pearl dashboard page,2026-10-11.
Keep the wallpaper hero. The visible page name is Dashboard (the private `today`
id stays compatible with existing tab preferences).

Below the hero, align three columns on one bottom edge: a month calendar spanning
all remaining height; restored logo/username/OS/compositor/uptime/update details
above three compact CPU, memory and storage circles; compact current-player card
above an upward real-audio spectrum. The spectrum runs bottom-primary through
secondary to top-tertiary. No synthetic beats. Paused/unavailable audio is quiet.
Use the existing single shared Cava owner, now visible on Dashboard or Media;
lyrics and album extraction remain restricted to Media. Preserve capability
checks, visible-only resources, reduced motion and closed-panel input release.

The first page may grow to736logical pixels to fit a useful calendar and cover;
other pages keep their current size. Narrow views stack the same blocks and use
FastScroll. Ring/spectrum changes animate finitely, never idle-loop.

Native proof: real Qt lower-section geometry shares one bottom baseline; compact
media controls fit bounds, missing readings remain unknown, spectrum changes
height from real supplied samples and respects inactivity/reduced motion. Full
checks, Hyprland verification, plan/apply, source/live navigation and CI follow.
