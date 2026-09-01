# zsh Modular Config Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the single `zsh/zshrc` with a short loader plus numbered `zsh/conf.d/*.zsh` modules, gate bat/eza/yazi aliases to interactive human shells, and drop dead blocks.

**Architecture:** `zsh/zshrc` resolves its own symlinked path, sources `conf.d/*.zsh` in glob order, then `~/.zshrc.local`. Each module owns one concern. Modules are built first alongside the old file, then the loader replaces the old file in one commit so the shell never breaks mid-migration.

**Tech Stack:** zsh 5.9, oh-my-posh, fzf, zsh-autosuggestions, zsh-syntax-highlighting, direnv, zoxide, atuin, mise. Spec: `docs/superpowers/specs/2026-09-01-zsh-modular-config-design.md`.

## Global Constraints

- Repo is public: no secrets, hostnames, or client names in any tracked file.
- No code comments except genuinely non-obvious reasoning notes (user policy). The notes the spec lists as surviving: NVIM_APPNAME rationale, CORRECT left off, Mason bin appended not prepended, bat `-n` vs `--plain`, atuin up-arrow, compinit touch.
- `~/.zshrc -> zsh/zshrc` symlink and `~/.zshrc.local` contract unchanged.
- Startup stays within the 50–100 ms baseline (`/usr/bin/time -p zsh -ic exit`).
- Every optional tool stays guarded via `(( $+commands[x] ))` or `_cached_init`.
- Every commit message ends with `Claude-Session: https://claude.ai/code/session_01H9sNWWgQyeTZX7rkuRdsUL`.
- Work in `~/dot-files` on `main`. Do not touch `~/.zshrc.local`.
- Verification commands run in a subshell so the live shell stays untouched until Task 4.

---

### Task 1: Options, environment, and PATH modules

**Files:**
- Create: `zsh/conf.d/00-options.zsh`
- Create: `zsh/conf.d/10-env.zsh`
- Create: `zsh/conf.d/20-path.zsh`

**Interfaces:**
- Produces: `$GOPATH` (used by `20-path`), `$RIPGREP_CONFIG_PATH`, `$FZF_*` (used by fzf in `60-tools`), `path` array with Mason bin appended.

- [ ] **Step 1: Write the verification script**

Create `/private/tmp/claude-501/-Users-fernandoruizguzman/c069cae2-18e1-4189-be04-9770b2031b09/scratchpad/t1.zsh`:

```zsh
#!/bin/zsh
set -e
d=~/dot-files/zsh/conf.d
for f in 00-options 10-env 20-path; do zsh -n $d/$f.zsh; done
zsh -c '
  source ~/dot-files/zsh/conf.d/00-options.zsh
  source ~/dot-files/zsh/conf.d/10-env.zsh
  source ~/dot-files/zsh/conf.d/20-path.zsh
  [[ -o SHARE_HISTORY && -o AUTO_PUSHD && ! -o CORRECT ]] || { echo "setopts wrong"; exit 1 }
  [[ $HISTSIZE == 50000 && $EDITOR == nvim && $NVIM_APPNAME == lazyvim ]] || { echo "env wrong"; exit 1 }
  [[ ${path[1]} == $HOME/go-workspace/bin ]] || { echo "path[1]=${path[1]}"; exit 1 }
  [[ ${path[-1]} == $HOME/.local/share/lazyvim/mason/bin ]] || { echo "mason not last"; exit 1 }
  (( ${path[(I)$HOME/bin]} == 0 )) || { echo "~/bin present"; exit 1 }
  (( ${path[(I)*antigravity*]} == 0 )) || { echo "antigravity present"; exit 1 }
  echo OK
'
```

- [ ] **Step 2: Run it to verify it fails**

Run: `zsh /private/tmp/claude-501/-Users-fernandoruizguzman/c069cae2-18e1-4189-be04-9770b2031b09/scratchpad/t1.zsh`
Expected: FAIL, `zsh -n` reports no such file for `00-options.zsh`.

- [ ] **Step 3: Create `zsh/conf.d/00-options.zsh`**

```zsh
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
setopt EXTENDED_HISTORY
setopt HIST_VERIFY
setopt HIST_FIND_NO_DUPS

setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
# CORRECT is deliberately off: it flags valid per-project binaries and git
# subcommands ("correct 'rails' to 'rail'?").
```

- [ ] **Step 4: Create `zsh/conf.d/10-env.zsh`**

```zsh
export EDITOR="nvim"
export VISUAL="nvim"

# Neovim loads under the `lazyvim` app-name: config from ~/.config/lazyvim,
# data (including Mason packages) from ~/.local/share/lazyvim. Without this,
# plain `nvim` looks in ~/.local/share/nvim and finds no language servers.
export NVIM_APPNAME="lazyvim"

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export ERL_AFLAGS="-kernel shell_history enabled"
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"
export GOPATH="$HOME/go-workspace"
export CLAUDE_CODE_NO_FLICKER=1
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons {}'"
```

- [ ] **Step 5: Create `zsh/conf.d/20-path.zsh`**

```zsh
typeset -U path
path=(
  "$GOPATH/bin"
  "$HOME/.local/bin"
  "/opt/homebrew/opt/libpq/bin"
  $path
  # Appended, not prepended, so project binstubs and `bundle exec` win over
  # Neovim's Mason-managed tools (ruby-lsp, rubocop, prettier, eslint_d, ...).
  "$HOME/.local/share/lazyvim/mason/bin"
)
export PATH
```

- [ ] **Step 6: Run the verification script**

Run: `zsh /private/tmp/claude-501/-Users-fernandoruizguzman/c069cae2-18e1-4189-be04-9770b2031b09/scratchpad/t1.zsh`
Expected: `OK`

- [ ] **Step 7: Commit**

```bash
cd ~/dot-files
git add zsh/conf.d/00-options.zsh zsh/conf.d/10-env.zsh zsh/conf.d/20-path.zsh
git commit -m "feat(zsh): add options, env, and path conf.d modules

Claude-Session: https://claude.ai/code/session_01H9sNWWgQyeTZX7rkuRdsUL"
```

---

### Task 2: Prompt, completion, tools, mise, and terminal modules

**Files:**
- Create: `zsh/conf.d/30-prompt.zsh`
- Create: `zsh/conf.d/50-completion.zsh`
- Create: `zsh/conf.d/60-tools.zsh`
- Create: `zsh/conf.d/70-mise.zsh`
- Create: `zsh/conf.d/80-terminal.zsh`

**Interfaces:**
- Consumes: `path` from Task 1 so `$+commands[...]` lookups resolve.
- Produces: `_cached_init <tool> <args...>` function (defined in `60-tools.zsh`, used only there); `_autosuggest_or_complete` zle widget bound to Tab.

- [ ] **Step 1: Write the verification script**

Create `/private/tmp/claude-501/-Users-fernandoruizguzman/c069cae2-18e1-4189-be04-9770b2031b09/scratchpad/t2.zsh`:

```zsh
#!/bin/zsh
set -e
d=~/dot-files/zsh/conf.d
for f in 30-prompt 50-completion 60-tools 70-mise 80-terminal; do zsh -n $d/$f.zsh; done
grep -q starship $d/30-prompt.zsh && { echo "starship still present"; exit 1 }
grep -qiE 'kiro|iterm2' $d/80-terminal.zsh && { echo "kiro/iterm2 still present"; exit 1 }
grep -rq conda $d && { echo "conda still present"; exit 1 }
zsh -ic '
  for f in ~/dot-files/zsh/conf.d/{10-env,20-path,30-prompt,50-completion,60-tools,70-mise,80-terminal}.zsh; do source $f; done
  typeset -f _cached_init >/dev/null || { echo "no _cached_init"; exit 1 }
  [[ ${widgets[_autosuggest_or_complete]} ]] || { echo "no tab widget"; exit 1 }
  [[ $(bindkey "^I") == *_autosuggest_or_complete* ]] || { echo "tab not bound"; exit 1 }
  typeset -f __zoxide_z >/dev/null || { echo "zoxide not initialised"; exit 1 }
  typeset -f _direnv_hook >/dev/null || { echo "direnv not initialised"; exit 1 }
  typeset -f mise >/dev/null || { echo "mise not activated"; exit 1 }
  [[ -n $PROMPT && $PROMPT != "%m%# " ]] || { echo "prompt not set"; exit 1 }
  echo OK
' 2>&1 | grep -v "can.t change option: zle"
```

- [ ] **Step 2: Run it to verify it fails**

Run: `zsh /private/tmp/claude-501/-Users-fernandoruizguzman/c069cae2-18e1-4189-be04-9770b2031b09/scratchpad/t2.zsh`
Expected: FAIL on `zsh -n` for missing `30-prompt.zsh`.

- [ ] **Step 3: Create `zsh/conf.d/30-prompt.zsh`**

```zsh
_omp_config="$HOME/.config/oh-my-posh/atomic.omp.json"
if (( $+commands[oh-my-posh] )) && [[ -f "$_omp_config" ]]; then
  _omp_cache="$HOME/.cache/oh-my-posh-init.zsh"
  if [[ ! -f "$_omp_cache" || "$_omp_config" -nt "$_omp_cache" || "${commands[oh-my-posh]}" -nt "$_omp_cache" ]]; then
    oh-my-posh init zsh --config "$_omp_config" > "$_omp_cache"
  fi
  source "$_omp_cache"
fi
unset _omp_config _omp_cache
```

- [ ] **Step 4: Create `zsh/conf.d/50-completion.zsh`**

```zsh
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
  # compinit only rewrites the dump on changes; touch resets the 24h clock.
  touch ~/.zcompdump
else
  compinit -C
fi

zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.cache/zcompcache"
```

- [ ] **Step 5: Create `zsh/conf.d/60-tools.zsh`**

```zsh
_cached_init() {
  (( $+commands[$1] )) || return
  local cache="$HOME/.cache/zsh-init-$1.zsh"
  [[ -f "$cache" && ! "${commands[$1]}" -nt "$cache" ]] || "$@" > "$cache"
  source "$cache"
}

_cached_init fzf --zsh

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null

_autosuggest_or_complete() {
  if [[ -n "$POSTDISPLAY" ]]; then
    zle autosuggest-accept
  else
    zle expand-or-complete
  fi
}
zle -N _autosuggest_or_complete
bindkey '\t' _autosuggest_or_complete

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

_cached_init direnv hook zsh
_cached_init zoxide init zsh
# Up-arrow is left to prefix search / autosuggestions; atuin only takes ctrl-r.
_cached_init atuin init zsh --disable-up-arrow
```

- [ ] **Step 6: Create `zsh/conf.d/70-mise.zsh`**

```zsh
_mise_bin="$HOME/.local/bin/mise"
_mise_cache="$HOME/.cache/mise-activate.zsh"
if [[ -x "$_mise_bin" ]]; then
  if [[ ! -f "$_mise_cache" || "$_mise_bin" -nt "$_mise_cache" ]]; then
    "$_mise_bin" activate zsh > "$_mise_cache"
  fi
  source "$_mise_cache"
fi
unset _mise_bin _mise_cache
```

- [ ] **Step 7: Create `zsh/conf.d/80-terminal.zsh`**

```zsh
[[ "$TERM_PROGRAM" == "ghostty" ]] && export TERM=xterm-256color
```

- [ ] **Step 8: Run the verification script**

Run: `zsh /private/tmp/claude-501/-Users-fernandoruizguzman/c069cae2-18e1-4189-be04-9770b2031b09/scratchpad/t2.zsh`
Expected: `OK`. If the `__zoxide_z` or `_direnv_hook` names fail, check `~/.cache/zsh-init-zoxide.zsh` / `zsh-init-direnv.zsh` for the actual function name and adjust the test, not the module.

- [ ] **Step 9: Commit**

```bash
cd ~/dot-files
git add zsh/conf.d/30-prompt.zsh zsh/conf.d/50-completion.zsh zsh/conf.d/60-tools.zsh zsh/conf.d/70-mise.zsh zsh/conf.d/80-terminal.zsh
git commit -m "feat(zsh): add prompt, completion, tools, mise, and terminal conf.d modules

Drops the starship fallback, kiro and iTerm2 integrations, and the lazy
conda init; none are in use on any machine.

Claude-Session: https://claude.ai/code/session_01H9sNWWgQyeTZX7rkuRdsUL"
```

---

### Task 3: Alias modules with the interactive gate

**Files:**
- Create: `zsh/conf.d/40-aliases.zsh`
- Create: `zsh/conf.d/41-interactive.zsh`

**Interfaces:**
- Produces: `wks` function, `WORKSPACE` default, all typed shortcuts; `y` function and bat/eza aliases only when `[[ -o interactive && -z $CLAUDECODE ]]`.

- [ ] **Step 1: Write the verification script**

Create `/private/tmp/claude-501/-Users-fernandoruizguzman/c069cae2-18e1-4189-be04-9770b2031b09/scratchpad/t3.zsh`:

```zsh
#!/bin/zsh
set -e
d=~/dot-files/zsh/conf.d
zsh -n $d/40-aliases.zsh
zsh -n $d/41-interactive.zsh
grep -qE "alias (rg|grep)=" $d/40-aliases.zsh $d/41-interactive.zsh && { echo "rg/grep alias present"; exit 1 }

human=$(zsh -ic 'unset CLAUDECODE; source ~/dot-files/zsh/conf.d/40-aliases.zsh; source ~/dot-files/zsh/conf.d/41-interactive.zsh; alias; typeset -f y wks >/dev/null && echo FUNCS_OK' 2>/dev/null)
for a in "cat=" "ls=" "ll=" "tree=" "less=" "dc=" "gs=" "be=" "mt=" "iexs="; do
  [[ $human == *"$a"* ]] || { echo "human shell missing alias $a"; exit 1 }
done
[[ $human == *FUNCS_OK* ]] || { echo "human shell missing y/wks"; exit 1 }

claude=$(CLAUDECODE=1 zsh -ic 'source ~/dot-files/zsh/conf.d/40-aliases.zsh; source ~/dot-files/zsh/conf.d/41-interactive.zsh; alias; typeset -f y >/dev/null && echo Y_PRESENT; typeset -f wks >/dev/null && echo WKS_OK' 2>/dev/null)
for a in "cat=" "ls=" "ll=" "tree=" "less="; do
  [[ $claude != *"$a"* ]] || { echo "claude shell has alias $a"; exit 1 }
done
for a in "dc=" "gs=" "be=" "mt=" "iexs="; do
  [[ $claude == *"$a"* ]] || { echo "claude shell missing alias $a"; exit 1 }
done
[[ $claude != *Y_PRESENT* && $claude == *WKS_OK* ]] || { echo "claude shell function set wrong"; exit 1 }

noninteractive=$(zsh -c 'source ~/dot-files/zsh/conf.d/41-interactive.zsh; alias' 2>/dev/null)
[[ -z $noninteractive ]] || { echo "non-interactive shell got aliases"; exit 1 }
echo OK
```

- [ ] **Step 2: Run it to verify it fails**

Run: `zsh /private/tmp/claude-501/-Users-fernandoruizguzman/c069cae2-18e1-4189-be04-9770b2031b09/scratchpad/t3.zsh`
Expected: FAIL on `zsh -n` for missing `40-aliases.zsh`.

- [ ] **Step 3: Create `zsh/conf.d/40-aliases.zsh`**

```zsh
: ${WORKSPACE:="$HOME/workspace"}

# A function so it can explain itself: when WORKSPACE is a symlink into an
# unmounted /Volumes drive, a bare "no such file or directory" hides the cause.
wks() {
  if [[ ! -d "$WORKSPACE" ]]; then
    print -u2 "wks: WORKSPACE does not resolve: $WORKSPACE"
    if [[ -L "$WORKSPACE" ]]; then
      print -u2 "wks: dangling symlink -> $(readlink "$WORKSPACE") — volume not mounted?"
    fi
    return 1
  fi
  cd "$WORKSPACE"
}

alias dc='docker compose'
alias dps='docker compose ps'
alias dl='docker logs -f'
alias dex='docker exec -it'
alias dstat='docker stats --no-stream'
alias docker-clean='docker system prune -af --volumes'

alias g='git'
alias ga='git add'
alias gc='git commit'
alias gs='git status'
alias gco='git checkout'
alias gl='git log --oneline --graph --decorate'
alias lg='lazygit'

alias be='bundle exec'
alias rc='bin/rails console'
alias rs='bin/rails server'
alias rdm='bin/rails db:migrate'
alias rt='bin/rails test'

alias mps='mix phx.server'
alias mdg='mix deps.get'
alias mt='mix test'
alias iexs='iex -S mix'
```

- [ ] **Step 4: Create `zsh/conf.d/41-interactive.zsh`**

```zsh
# Human-only. Claude Code snapshots the interactive shell and exports
# CLAUDECODE; bat's line numbers would corrupt its `cat a > b` redirects and
# eza prints nothing there when run without a path.
[[ -o interactive && -z "$CLAUDECODE" ]] || return

alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --git'
alias tree='eza --tree --icons'
# `-n` shows line numbers; `--plain` would cancel it. `--paging=never` keeps
# pipes and redirects clean.
alias cat='bat -n --paging=never'
alias less='bat --paging=always'

y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}
```

- [ ] **Step 5: Run the verification script**

Run: `zsh /private/tmp/claude-501/-Users-fernandoruizguzman/c069cae2-18e1-4189-be04-9770b2031b09/scratchpad/t3.zsh`
Expected: `OK`

- [ ] **Step 6: Commit**

```bash
cd ~/dot-files
git add zsh/conf.d/40-aliases.zsh zsh/conf.d/41-interactive.zsh
git commit -m "feat(zsh): split aliases; gate bat/eza/yazi to interactive human shells

Claude Code inherits every alias. bat -n wrote line numbers into cat
redirects and eza printed nothing without a path. The rg and grep aliases
go: smart-case already comes from ripgrep/config and Claude Code overrides
grep with its own function.

Claude-Session: https://claude.ai/code/session_01H9sNWWgQyeTZX7rkuRdsUL"
```

---

### Task 4: Replace `zsh/zshrc` with the loader and verify end to end

**Files:**
- Modify: `zsh/zshrc` (full replacement; currently 280 lines)

**Interfaces:**
- Consumes: every `zsh/conf.d/*.zsh` from Tasks 1–3.
- Produces: the live `~/.zshrc` behaviour.

- [ ] **Step 1: Record the baseline startup time**

Run:
```bash
for i in 1 2 3; do /usr/bin/time -p zsh -ic exit 2>&1 | grep real; done
```
Expected: three values between 0.05 and 0.10. Note them.

- [ ] **Step 2: Write the end-to-end verification script**

Create `/private/tmp/claude-501/-Users-fernandoruizguzman/c069cae2-18e1-4189-be04-9770b2031b09/scratchpad/t4.zsh`:

```zsh
#!/bin/zsh
set -e
zsh -n ~/dot-files/zsh/zshrc
for f in ~/dot-files/zsh/conf.d/*.zsh; do zsh -n $f; done
[[ $(wc -l < ~/dot-files/zsh/zshrc) -le 20 ]] || { echo "loader too long"; exit 1 }

human=$(zsh -ic 'unset CLAUDECODE; source ~/.zshrc; alias | wc -l | tr -d " "; typeset -f y wks _cached_init >/dev/null && echo FUNCS_OK; [[ -n $KAMAL_REGISTRY_PASSWORD || -n $GEMINI_MODEL ]] && echo LOCAL_OK' 2>/dev/null)
[[ $human == *FUNCS_OK* && $human == *LOCAL_OK* ]] || { echo "human: $human"; exit 1 }

scratch=/private/tmp/claude-501/-Users-fernandoruizguzman/c069cae2-18e1-4189-be04-9770b2031b09/scratchpad
printf 'alpha\nbeta\n' > $scratch/src.txt
CLAUDECODE=1 zsh -ic "source ~/.zshrc; cat $scratch/src.txt > $scratch/copy.txt; ls $scratch | grep -q src.txt || { echo 'ls empty'; exit 1 }" 2>/dev/null
cmp $scratch/src.txt $scratch/copy.txt || { echo "cat redirect corrupted"; exit 1 }
claude_aliases=$(CLAUDECODE=1 zsh -ic 'source ~/.zshrc; alias' 2>/dev/null)
for a in "cat=" "ls=" "less=" "rg=" "grep="; do
  [[ $claude_aliases != *"$a"* ]] || { echo "claude shell has $a"; exit 1 }
done

for i in 1 2 3; do /usr/bin/time -p zsh -ic exit 2>&1 | grep real; done
echo OK
```

- [ ] **Step 3: Run it to verify it fails**

Run: `zsh /private/tmp/claude-501/-Users-fernandoruizguzman/c069cae2-18e1-4189-be04-9770b2031b09/scratchpad/t4.zsh`
Expected: FAIL at "loader too long" (old file is 280 lines).

- [ ] **Step 4: Replace `zsh/zshrc` with the loader**

Overwrite the whole file with:

```zsh
# Shared across machines. Private, host-specific, or path-dependent settings
# belong in ~/.zshrc.local, sourced last and never tracked.
#
# %x is the file being sourced; :A resolves the ~/.zshrc symlink so conf.d is
# found wherever the repo lives. Modules load in glob order; the numeric
# prefix is the ordering contract.
_zsh_conf_dir="${${(%):-%x}:A:h}/conf.d"
for _f in "$_zsh_conf_dir"/*.zsh(N); do
  source "$_f"
done
unset _f _zsh_conf_dir

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
```

- [ ] **Step 5: Run the end-to-end script**

Run: `zsh /private/tmp/claude-501/-Users-fernandoruizguzman/c069cae2-18e1-4189-be04-9770b2031b09/scratchpad/t4.zsh`
Expected: `OK`, preceded by three `real` values within the Step 1 baseline (allow up to 0.15 on a cold cache).

- [ ] **Step 6: Open a fresh terminal tab and smoke test by hand**

Check: prompt renders with oh-my-posh, `ll` shows icons, Tab accepts a grey autosuggestion, `z <dir>` jumps, `cd` into a mise project prints no error, `wks` changes directory.

- [ ] **Step 7: Commit**

```bash
cd ~/dot-files
git add zsh/zshrc
git commit -m "refactor(zsh): zshrc becomes a conf.d loader

Claude-Session: https://claude.ai/code/session_01H9sNWWgQyeTZX7rkuRdsUL"
```

---

### Task 5: Documentation

**Files:**
- Modify: `README.md:108-117` (prompt paragraph and requirements)
- Modify: `README.md:262-263` (structure tree)
- Modify: `CLAUDE.md:7` (repository overview)

- [ ] **Step 1: Write the doc check**

Run after edits:
```bash
cd ~/dot-files
grep -q 'conf.d' README.md && grep -q 'conf.d' CLAUDE.md && ! grep -q starship README.md && echo OK
```
Expected before edits: no output (starship still present).

- [ ] **Step 2: Replace the prompt paragraph in README**

Replace lines 108–113 (the paragraph starting `**2. The prompt degrades on purpose.**`) with:

```markdown
**2. Every tool is optional.** `zsh/conf.d/30-prompt.zsh` initialises
oh-my-posh only when it's installed *and* `~/.config/oh-my-posh/atomic.omp.json`
resolves; without it you get zsh's default prompt. Every other optional tool is
guarded through the `_cached_init` helper in `60-tools.zsh`, which returns
early when the tool is missing, so a partially-provisioned machine still boots
a working shell.

**3. Display aliases are human-only.** `41-interactive.zsh` returns early
unless the shell is interactive and `CLAUDECODE` is unset. That keeps the
bat/eza/yazi replacements out of Claude Code's Bash tool, where `bat -n` wrote
line numbers into `cat a > b` redirects. Anything that must behave identically
for scripts and agents goes in `40-aliases.zsh` instead.
```

Then change line 115 to:

```markdown
**Requirements:** Neovim >= 0.9.0, Git, a [Nerd Font](https://www.nerdfonts.com/), and oh-my-posh.
```

- [ ] **Step 3: Replace the zsh entry in the structure tree**

Replace lines 262–263:

```
zsh/
└── zshrc                 # Shell config (history, aliases, fzf, cached tool inits)
```

with:

```
zsh/
├── zshrc                 # Loader: sources conf.d/*.zsh in order, then ~/.zshrc.local
└── conf.d/
    ├── 00-options.zsh    # History and setopts
    ├── 10-env.zsh        # Exports, FZF vars
    ├── 20-path.zsh       # PATH assembly (Mason bin appended last)
    ├── 30-prompt.zsh     # oh-my-posh, cached
    ├── 40-aliases.zsh    # docker/git/rails/mix shortcuts, wks
    ├── 41-interactive.zsh# bat/eza/yazi, interactive humans only
    ├── 50-completion.zsh # compinit cache and zstyles
    ├── 60-tools.zsh      # fzf, autosuggestions, highlighting, direnv, zoxide, atuin
    ├── 70-mise.zsh       # mise activate, cached, loads last
    └── 80-terminal.zsh   # Ghostty TERM override
```

- [ ] **Step 4: Update CLAUDE.md line 7**

Change `zsh (\`zsh/zshrc\`)` to `zsh (\`zsh/zshrc\` loader plus numbered modules in \`zsh/conf.d/\`)`.

- [ ] **Step 5: Run the doc check**

Run the command from Step 1. Expected: `OK`.

- [ ] **Step 6: Commit**

```bash
cd ~/dot-files
git add README.md CLAUDE.md
git commit -m "docs: describe the zsh conf.d layout and interactive gate

Claude-Session: https://claude.ai/code/session_01H9sNWWgQyeTZX7rkuRdsUL"
```
