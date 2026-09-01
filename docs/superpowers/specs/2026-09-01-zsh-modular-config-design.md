# zsh config overhaul: modular conf.d layout

## Problem

`zsh/zshrc` is a single 280-line file shared across machines. Two concrete
defects and some accumulated dead weight motivate the change:

1. **Aliases leak into Claude Code.** Claude Code snapshots the interactive
   shell, so every alias is active in its Bash tool. `cat='bat -n
   --paging=never'` writes line numbers into `cat a > b` redirects and into
   piped output. `ls='eza ...'` prints nothing at all when run without a path
   in that environment. Verified on 2026-09-01.
2. **Redundant search aliases.** `rg='rg --smart-case'` duplicates
   `ripgrep/config`. `grep='rg --smart-case'` is overridden by Claude Code's
   own `grep` function and changes grep semantics for humans.
3. **Dead guarded blocks.** starship fallback, kiro shell integration, lazy
   conda init, iTerm2 integration, the antigravity PATH entry, and `~/bin`
   reference tools no longer used on any machine.

## Goals

- Split the config into small single-purpose files so each concern can be
  read and edited in isolation.
- Confine display-oriented replacements (bat, eza, yazi) to interactive
  human shells.
- Remove the dead blocks and the redundant search aliases.
- Keep the install contract unchanged: `~/.zshrc -> zsh/zshrc`,
  `~/.zshrc.local` sourced last.
- Keep startup within the current 50–100 ms envelope.

## Non-goals

- No changes to ripgrep, oh-my-posh, Ghostty, or Neovim config.
- No new tools, plugins, or aliases.
- No change to `~/.zshrc.local` on any machine.

## Layout

```
zsh/
├── zshrc                  # loader
└── conf.d/
    ├── 00-options.zsh     # history vars + setopts
    ├── 10-env.zsh         # EDITOR/VISUAL, NVIM_APPNAME, LANG/LC_ALL, ERL_AFLAGS,
    │                      # RIPGREP_CONFIG_PATH, GOPATH, CLAUDE_CODE_NO_FLICKER,
    │                      # MANPAGER, LDFLAGS/CPPFLAGS, FZF_* vars
    ├── 20-path.zsh        # typeset -U path; prepend $GOPATH/bin, ~/.local/bin,
    │                      # /opt/homebrew/opt/libpq/bin; append Mason bin
    ├── 30-prompt.zsh      # oh-my-posh init, cached on config/binary mtime
    ├── 40-aliases.zsh     # docker, git, rails, mix shortcuts; WORKSPACE + wks()
    ├── 41-interactive.zsh # bat/eza aliases + y(); gated, see below
    ├── 50-completion.zsh  # compinit with 24 h cache + zstyles
    ├── 60-tools.zsh       # _cached_init; fzf, zsh-autosuggestions + tab
    │                      # binding, zsh-syntax-highlighting, direnv, zoxide, atuin
    ├── 70-mise.zsh        # mise activate, cached; must load after other tools
    └── 80-terminal.zsh    # Ghostty TERM override
```

### Loader (`zsh/zshrc`)

```zsh
_zsh_conf_dir="${${(%):-%x}:A:h}/conf.d"
for _f in "$_zsh_conf_dir"/*.zsh(N); do
  source "$_f"
done
unset _f _zsh_conf_dir
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
```

`${(%):-%x}` is the path of the file being sourced; `:A` resolves the
`~/.zshrc` symlink to the repo file so `conf.d` is found regardless of where
the repo lives. Files load in glob order; the numeric prefix is the ordering
contract. `(N)` makes an empty directory a no-op rather than an error.

### Ordering constraints

- `10-env` before `20-path` (PATH uses `$GOPATH`).
- `20-path` before `30-prompt` and `60-tools` (they look up binaries).
- `50-completion` before `60-tools` (fzf and plugins bind into the completion
  system).
- `70-mise` after `60-tools` (mise's hook must be last to win on PATH).
- `~/.zshrc.local` last, unchanged.

### Interactive gate (`41-interactive.zsh`)

```zsh
[[ -o interactive && -z "$CLAUDECODE" ]] || return
```

Everything below the guard is human-only: `ls`, `ll`, `tree` (eza), `cat`,
`less` (bat), and the `y` yazi cd-wrapper. `CLAUDECODE` is exported by
Claude Code in its Bash tool; the `-o interactive` check covers other
non-interactive consumers (scripts, `zsh -c`).

### Alias disposition

| Alias / function | Disposition |
|---|---|
| `cat`, `less`, `ls`, `ll`, `tree`, `y` | move to `41-interactive.zsh` behind the gate |
| `rg`, `grep` | removed |
| `dc dps dl dex dstat docker-clean` | keep, `40-aliases.zsh` |
| `g ga gc gs gco gl lg` | keep, `40-aliases.zsh` |
| `be rc rs rdm rt` | keep, `40-aliases.zsh` |
| `mps mdg mt iexs` | keep, `40-aliases.zsh` |
| `wks`, `WORKSPACE` default | keep, `40-aliases.zsh` |

### Removed

- starship fallback in the prompt block
- kiro shell integration
- lazy `conda` function and its miniforge check
- iTerm2 shell integration
- `$HOME/.antigravity/antigravity/bin` and `$HOME/bin` PATH entries
- Comment prose that restates what the code says; only non-obvious notes
  survive (NVIM_APPNAME rationale, CORRECT left off, Mason bin appended not
  prepended, bat `-n` vs `--plain`, atuin up-arrow, compinit touch).

## Documentation

- `README.md`: zsh section describes `conf.d`, the numbering contract, and
  the interactive gate; the file tree lists the new files.
- `CLAUDE.md`: one line in Repository Overview pointing at `zsh/conf.d/`.
- `.gitignore`: unchanged.

## Verification

1. `zsh -n` on `zsh/zshrc` and every `conf.d/*.zsh` file.
2. `zsh -ic 'alias; typeset -f wks y'` shows the full alias set and both
   functions.
3. `CLAUDECODE=1 zsh -ic 'alias'` shows no `cat`, `less`, `ls`, `ll`,
   `tree`, `rg`, or `grep` alias and no `y` function.
4. `zsh -ic 'cat file > copy && cmp file copy'` succeeds under `CLAUDECODE=1`.
5. `for i in 1 2 3; do /usr/bin/time -p zsh -ic exit; done` stays within
   the 50–100 ms baseline measured 2026-09-01.
6. Interactive smoke test in a fresh terminal: prompt renders, `ll` shows
   icons, tab accepts autosuggestion, `z`, `direnv`, and `mise` activate.

## Rollout

Single commit on `main` in `dot-files`. The other machine picks it up on
pull with no install change; anything it needs from the removed blocks goes
in its `~/.zshrc.local`.
