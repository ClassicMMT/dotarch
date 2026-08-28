---
name: dotfiles
description: >
  REQUIRED before editing any config on this machine. This machine's configuration is
  GNU Stow-managed from ~/.dotfiles; ~/.config holds symlinks into it. Use when editing
  ~/.dotfiles/, ~/.config/hypr/, ~/.config/kitty/, ~/.config/nvim/, ~/.config/lazygit/,
  ~/.config/fontconfig/, ~/.zshrc, ~/.p10k.zsh, or /etc/keyd/. Triggers: dotfiles, stow,
  symlink, "is this tracked", "add this to my dotfiles", adopt, keyd, key remapping,
  Hyprland config, hypr, bindings, monitors, looknfeel, window rules, mouse acceleration,
  scroll curve, pointer tuning, kitty, nvim, zshrc, shell startup.
  Read alongside the `omarchy` skill: that one describes stock Omarchy and is updated by
  the package; this one describes how THIS machine deviates. Where they conflict, this
  file wins.
---

# Dotfiles (this machine)

This file records **decisions, procedures and hard-won gotchas** — things that cannot be
discovered by reading the system. It deliberately does not list files, commands or config
keys: look those up at read time. Anything enumerated here would rot.

## Read the omarchy skill too

Start here for "where does this file live and is it tracked", then read the Omarchy skill
for "how does this subsystem work". It lives at:

```
~/.claude/skills/omarchy/
```

List that directory and read `SKILL.md` first — it is the entry point and names its own
topic guides. Discover them at read time; the package adds and renames them between
releases.

That path is a symlink into `/usr/share/omarchy/`, which is owned by pacman. Read it
freely; never write to it.

## Precedence

Where this file and the `omarchy` skill disagree, **this file wins**. The most common
conflict: the stock skill says to edit files in `~/.config/`. On this machine most of
those are symlinks, and the file to edit is the matching path under `~/.dotfiles/`.

Contradict the stock skill only where following it would do real harm or lose work. Every
override is maintenance debt and a future conflict, so where its advice is merely
redundant or slightly inefficient, just follow it.

## Configuration lives in `~/.dotfiles` (GNU Stow)

**Default rule: make every config edit in `~/.dotfiles`, not directly in `~/.config`.**
The dotfiles repo is the source of truth; `~/.config` holds symlinks into it. Anything
edited only under `~/.config` is untracked, unversioned, and lost on a reinstall or a new
machine.

The mapping is positional: a repo path stows to the same path under `~`. So
`~/.dotfiles/.config/hypr/` is the Hyprland config, `~/.dotfiles/.config/kitty/` is kitty,
`~/.dotfiles/.zshrc` is the shell. Look inside those directories rather than trusting any
list. `etc/` is the one exception — see the `/etc` section below.

Installed with GNU stow from inside the repo: `cd ~/.dotfiles && stow -t ~ .`

Stow links per-file, so a directory like `~/.config/hypr/` legitimately contains a **mix**
of symlinks (managed) and real files (unmanaged). Always check which kind you are about to
edit:

```bash
ls -la <path>                  # '-> ../../.dotfiles/...' means managed
git -C ~/.dotfiles ls-files    # authoritative list of managed files
```

### Editing a file that is already managed

Edit the repo path. Writing through the symlink lands the same bytes, but using the repo
path keeps it obvious what is tracked. No `.bak` copies are needed — `git -C ~/.dotfiles
diff` is the backup.

### Adopting an unmanaged file into `~/.dotfiles`

When asked to change a config that is still a real file in `~/.config`, prefer moving it
into the repo and re-stowing over editing it in place:

```bash
mkdir -p ~/.dotfiles/.config/<app>
mv ~/.config/<app>/<file> ~/.dotfiles/.config/<app>/<file>
cd ~/.dotfiles && stow -t ~ .    # creates the symlink
ls -la ~/.config/<app>/<file>    # verify it is now a link
```

`stow --adopt -t ~ .` automates the move, but it **overwrites the repo copy** with
whatever is on the system — only run it with a clean `git status`, and diff afterwards.

If the live file is newer than the repo copy, copy live → repo *before* removing it.
Re-stowing over a diverged file silently reverts real work.

Say so when a file gets adopted: the change now needs committing.

### What must NOT go in `~/.dotfiles`

- Anything Omarchy replaces wholesale rather than edits — notably the current-theme state
  directory, which is `rm -rf`'d and recreated on every theme change, so a symlink there
  is destroyed rather than followed. Generated/templated theme output likewise.
- Custom theme directories must stay **real directories** (stock Omarchy rule).
- Runtime state: anything symlinked into `/run/user/$UID/`.
- Downloaded models and caches (`~/.cache/`) — they re-download on a new machine.
- Secrets, tokens, or machine-specific identifiers — the repo has a public remote.

### After any Omarchy command that rewrites config

Some Omarchy commands write **through** a symlink (silently overwriting the repo copy) and
others **replace** it with a real file (silently unlinking it from the repo). Which
commands do which changes between releases, so do not rely on a list — assume any command
that rewrites config can do either, and verify afterwards:

```bash
cd ~/.dotfiles && git status --short
git ls-files | grep -vE '^(etc/|README\.md|\.stow)' |
  while read -r f; do [ -L "$HOME/$f" ] || echo "no longer a symlink: ~/$f"; done
```

Recovery: `git -C ~/.dotfiles checkout -- <file>` if it was overwritten in place; if it
was unlinked, copy the live file into the repo, delete it from `~/.config`, and re-stow.

This is not hypothetical — the Omarchy 4 upgrade unlinked `kitty.conf` and the divergence
went unnoticed for a day. A major upgrade also leaves a backup of the previous tree at
`~/.local/share/omarchy.omarchy-upgrade-to-*.bak`; check there before assuming work is
lost.

### Config under `/etc` (keyd)

`etc/` is listed in `.stow-local-ignore`, so it is versioned but **not** symlinked. Edit
the repo copy, then install it by hand:

```bash
sudo cp ~/.dotfiles/etc/keyd/default.conf /etc/keyd/default.conf
sudo systemctl restart keyd
```

Do not edit `/etc/keyd/default.conf` directly — that change would be untracked.

keyd provides the macOS-style layer on this machine: the meta keys become a `cmd` layer
and the alt keys an `alt` layer. Keys not mapped in a layer pass through with the modifier
intact, so `SUPER + <unmapped>` still reaches Hyprland normally — keyd is rarely the
culprit when a Hyprland binding misbehaves.

### Committing

Leave commits to the user unless they ask. Do report which files under `~/.dotfiles`
changed so they can review and commit.

## Hyprland is Lua on this machine

Omarchy 4 / Hyprland 0.55+ deprecated hyprlang in favour of Lua. The config is
`~/.dotfiles/.config/hypr/` — read the directory. Helper functions (`o.bind`, `hl.*`) are
defined in Omarchy's defaults under `/usr/share/omarchy/default/hypr/`; read
`helpers.lua` there for the current API rather than assuming a signature.

Hyprland reloads on save by itself, including through the stow symlinks and on
`require`-ed modules, so the stock skill's `hyprctl reload` is redundant — but harmless,
and not worth avoiding.

What matters is the failure mode: **a Lua error does not surface anywhere.** Hyprland
drops the whole failing module and falls back to stock Omarchy defaults with no
notification, so a syntax error reads as "my change didn't apply" rather than "my config
is broken" — sending you hunting for a typo in the setting instead of in the file.
`hyprctl configerrors` is the only place the reason appears. Always check it after a
change.

Three more things that cost real debugging time:

- **`hl.unbind` is case-sensitive and must match the bind string exactly.** Unbinding
  `"SUPER + code:61"` does nothing if Omarchy bound `"SUPER + SLASH"`. Grep Omarchy's
  default bindings for the exact string first.
- **`hyprctl dispatch` takes Lua**, not the old string form, which now fails with
  `')' expected near ...`. Any script or snippet carrying pre-0.55 dispatcher syntax is
  broken — and if it swallows stderr, it fails *silently*.
- **`.luarc.json` must live beside the `.lua` files inside the repo.** lua_ls reads it
  from the workspace root; because the files resolve into `~/.dotfiles` (a git repo), a
  copy left in `~/.config/hypr/` is out of scope and every `hl`/`o` reference is flagged
  as an undefined global.

## Mouse / pointer / scroll acceleration

Configured in the Hyprland input config. Settings at the `input` level apply to all
pointer devices; a `touchpad` sub-table overrides for the touchpad; `hl.device` scoped by
libinput name (from `hyprctl devices`) targets a single device.

### Nonlinear (macOS-like) acceleration curves

For velocity-based curves — gentle at slow speeds for precision, accelerated on fast
flicks — use a custom `accel_profile` plus `scroll_points`. **Six gotchas that will
otherwise burn an hour:**

1. **`scroll_points` requires `accel_profile = "custom"`.** They are coupled through
   libinput's API. You cannot enable a custom scroll curve without also enabling a custom
   motion curve, which means **changing scroll always changes cursor behaviour** unless
   you also supply a motion curve matching the current cursor feel.

2. **`accel_profile` and `scroll_points` are *independent* curves**, even though both
   require `custom`. Internally they map to different `libinput_config_accel_type` values
   (MOTION vs SCROLL). Give them different point arrays when cursor and scroll want
   different tuning.

3. **`scroll_factor` stacks on top of `scroll_points`** as a flat multiplier. Scroll has
   two levers — *shape* (`scroll_points`) and *scale* (`scroll_factor`). Cursor only has
   the curve. Use `scroll_factor` to rescale without regenerating curves.

4. **Curve format is `custom <step> <p0> <p1> <p2>...`** — a single string. `step` is the
   velocity bucket size in device-units/ms; points are unitless multipliers sampled at
   `0*step, 1*step, 2*step, ...`. libinput interpolates linearly between adjacent points
   and extrapolates past the last one.

5. **A naive flat passthrough like `custom 1.0 1.0 1.0` makes the cursor feel like the DPI
   dropped to minimum.** libinput's default motion has a device-specific base multiplier
   > 1.0, so forcing 1.0 is much slower than default. Always generate a real curve, never
   placeholder values.

6. **macOS-style momentum/inertia cannot be reproduced at the libinput layer.**
   `scroll_points` gives velocity-based acceleration (fast flicks scroll farther). Real
   momentum is application-level — browsers and GTK4/Qt6 render their own. Don't promise
   inertia.

**Starting point:** fufexan's macOS-like gist —
`gist.github.com/fufexan/e6bcccb7787116b8f9c31160fc8bc543`. It uses a cubic:
`factor = low*v + mid*v² + high*v³`. The script is **not** DPI-aware — it emits raw
values, so coefficients usually need scaling up on hi-DPI screens. Tuning levers: `low`
for slow-end precision, `mid` for mid-range, `high` for fast flicks. For cursor and scroll
to feel different, generate the curve twice with different coefficients.

Tuning is trial and error: edit, reload, feel it, repeat. Verify the device block actually
matched with `hyprctl devices` — a real `scroll factor` (instead of `-1.00`) confirms the
per-device settings are live.

## Fetching Hyprland documentation

**The rendered wiki at `wiki.hypr.land` is unusable to an agent** — it is JS-rendered, so
WebFetch returns navigation chrome without content, and `llms.txt` 404s.

The wiki is a Hugo site whose source is plain markdown on GitHub. Pull that instead, and
find paths with the tree API rather than guessing them (they get restructured between
releases — quote the URL, `?` is a zsh glob):

```bash
gh api "repos/hyprwm/hyprland-wiki/git/trees/main?recursive=1" --jq '.tree[].path' | grep -i <topic>
gh api repos/hyprwm/hyprland-wiki/contents/<path> --jq '.content' | base64 -d
```

Paths containing spaces need `%20`. There is also a local Lua API stub under
`/usr/share/hypr/stubs/`.

**Window rule and dispatcher syntax changes between Hyprland releases.** Do not write
either from memory or from anything written here — fetch the current page first. This has
already broken this machine's config twice.

## Customizations on this machine

A running log of bespoke keybindings and customizations, so they can be recalled,
explained, or changed later. Add new entries over time. This exists because reconstructing
*why* from `git log -p` is far more expensive than reading it here.

- **kitty keybindings** — `Alt+y` copies all output of the last command (everything since
  the previous shell prompt) to the clipboard. `Shift+Enter` and `Alt+Shift+Enter` send
  CSI-u sequences so tmux can distinguish them; kitty's legacy encoding otherwise
  collapses `Alt+Shift+Enter` into `Alt+Enter`.
- **Lower-contrast theming (NOT the omarchy theme)** — a one-off pass desaturated several
  configs independently of the omarchy Tokyo Night theme, which is untouched. Each is
  hue-preserving (saturation reduced, sometimes lightness) and revertible:
  - **kitty** — the palette is self-contained, not from omarchy; softened cursor, ANSI
    colors and selection. This drives **Claude Code** and any TUI using ANSI colors (e.g.
    lazygit). Originals are commented inline, marked "Lower-contrast tweak: desaturated,
    hue preserved". Reload with `Ctrl+Shift+F5`.
  - **nvim** — NvChad onedark desaturated via a `changed_themes` block in `chadrc.lua`
    (revert: comment it out, then `:Lazy build base46`).
  - **p10k** — Powerlevel10k segment colors desaturated ~42%; git colors
    (`my_git_formatter` and the VCS fallbacks) dimmed separately. A note at line 1 records
    the pass; reload with `source ~/.p10k.zsh`.
  - **lazygit** — `selectedLineBgColor` set to a dark navy; the default `blue` was too
    bright on Tokyo Night. It takes a YAML **list**, not a scalar.

  Pre-desaturation `.bak.*` files exist next to the kitty and p10k configs, but they are
  **untracked** — they will not exist on a new machine, so the inline comments are the
  portable record, not the backups.
- **lazygit auto-return** — `promptToReturnFromSubprocess: false` must sit at **top
  level**; nesting it under `gui` makes lazygit silently ignore it, and `gui` is right
  below it in the file, so this is an easy mistake to make.
- **zsh startup** — `fpath+=~/.zfunc` must stay immediately *before* the single
  `compinit`. It previously ran near the end of the file, after an earlier `compinit`,
  which invalidated the completion cache and forced a full `compdump` on every shell
  start: ~1030 ms, of which the compinit family was ~740 ms. One `compinit` with a settled
  `fpath` takes ~24 ms. Powerlevel10k was also being sourced twice. If startup regresses,
  profile rather than guess:
  `printf 'zmodload zsh/zprof\nsource ~/.zshrc\nzprof\n' > /tmp/zp/.zshrc && ZDOTDIR=/tmp/zp zsh -i -c exit`
- **Dictation** — hyprwhspr with the `onnx-asr` backend running **parakeet-tdt-0.6b-v3**
  (int8) plus silero-vad, not whisper. Chosen because this machine has no discrete GPU:
  parakeet on CPU is far faster than whisper on CPU at comparable accuracy, which is what
  Voxtype's own docs recommend for CPU-only English. Omarchy ships Voxtype as an opt-in
  install, but its default config uses whisper `base.en` — installing it as shipped would
  be a downgrade here. `word_overrides` fixes terms the model mishears; matching is
  case-insensitive and word-boundary anchored, so plurals need their own entries. Restart
  the user service after editing.
- **`SUPER+E` — gridify/equalize columns** — a script bound in the Hyprland bindings
  equalizes column widths on the focused monitor's active workspace, turning dwindle's
  uneven 1/2,1/4,1/4 row into equal 1/N columns. Vertical stacks inside a column follow
  (widths only change; stack heights preserved). Idempotent. Key dwindle facts baked into
  it, worth recalling for ANY future window-resize scripting:
  - **dwindle is a guillotine layout**, so columns (full-height vertical slabs) are
    recoverable from window geometry via a left-to-right sweep — a column = windows
    sharing an x-band; a spanning window merges two slabs. BUT geometry does **not**
    reveal the binary tree: left-leaning `((a|b)|c)` and right-leaning `(a|(b|c))` produce
    identical rectangles.
  - **Which divider a window controls is tree-dependent and cannot be inferred from
    geometry** — so MEASURE: nudge a candidate, re-read, keep if the target divider moved,
    else revert with an equal-opposite nudge and try the next candidate.
  - **Bounded passes, never "until converged".** A fixed pass count guarantees termination
    in well under a second; the unbounded version thrashed forever on a 6-window
    double-nested workspace.
  - **Hard dwindle limitation — some dividers are unmovable:** a divider with multi-window
    GROUPS on both sides (e.g. the root split of `((a|b)|(c|d))`) is moved by NO
    single-window resize. `layoutmsg splitratio` cannot reach it either — it only sets the
    focused window's *immediate* parent split, which is also the wrong axis for a stacked
    pane. Only a mouse drag moves it. The script leaves such a divider alone and grids
    every other column around it.
  - **Target = equal widths with current inter-column gaps preserved** (total span
    conserved) → self-calibrating, no gap/border model needed.
  - **The resize call broke once already, silently.** It carried pre-0.55 dispatcher
    syntax that Hyprland now rejects, and because the helper swallows stderr every resize
    failed quietly — so the script reported "one divider is unmovable (dwindle limit)", a
    plausible-looking message for entirely the wrong reason. If gridify ever stops
    working, run the dispatch by hand and read the error before believing the script's own
    diagnosis.
