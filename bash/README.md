# Linux/bash port of github.com/fruizg0302/dot-files

Adapted 2026-09-09 for Arch + Omarchy + bash 5.3. The Mac repo is zsh +
oh-my-posh + Homebrew; this machine is bash with Omarchy's own rc providing
mise, zoxide, fzf bindings and a set of aliases/functions. Oh My Posh supplies
the prompt using the same Atomic theme as macOS.

## Layout

`~/.config/bash` is a symlink to this directory, so these modules are tracked
in the repo exactly like `zsh/conf.d`. `~/.bashrc` sources Omarchy's rc first,
then the `~/.config/bash/conf.d/*.bash` modules in glob order (except the prompt),
then `~/.bashrc.local`, and finally `30-prompt.bash`. The numeric prefixes mirror `zsh/conf.d/`
in the repo and are the ordering contract. Loading *after* Omarchy is what lets
these modules override its aliases and append to its `PROMPT_COMMAND`.

| module | source | notes |
|---|---|---|
| `00-options.bash` | `00-options.zsh` | setopts → shopt; `SHARE_HISTORY` → `history -a; history -n` appended to `PROMPT_COMMAND` |
| `10-env.bash` | `10-env.zsh` | dropped Homebrew `LDFLAGS`/`CPPFLAGS`; `MANPAGER` left to Omarchy; no `NVIM_APPNAME` |
| `20-path.bash` | `20-path.zsh` | dropped `/opt/homebrew/opt/libpq/bin`; Mason path is `~/.local/share/nvim/mason/bin` |
| `30-prompt.bash` | `30-prompt.zsh` | Oh My Posh Atomic by default; `OMP_THEME` selects another theme or `starship` |
| `40-aliases.bash` | `40-aliases.zsh` | verbatim, plus a shim that moves Omarchy's `ga`/`gd` worktree helpers to `gwa`/`gwd` |
| `41-interactive.bash` | `41-interactive.zsh` | same `interactive && ! CLAUDECODE` guard; `y()` guarded on yazi |
| `50-completion.bash` | `50-completion.zsh` | mostly already covered by Omarchy's inputrc; see file |
| `60-tools.bash` | `60-tools.zsh` + `70-mise.zsh` | mise/zoxide/fzf are Omarchy's; direnv/atuin guarded |

`80-terminal.zsh` (Ghostty `TERM` override) has no port: Ghostty isn't installed
and foot already sets `term=xterm-256color`.

## Installation

Link `bash/` to `~/.config/bash`, then add this loader after Omarchy's rc and
the interactive-shell guard in `~/.bashrc`:

```bash
for _f in "$HOME"/.config/bash/conf.d/*.bash; do
  [[ $_f == */30-prompt.bash ]] && continue
  [[ -r $_f ]] && source "$_f"
done
unset _f
[[ -r "$HOME/.bashrc.local" ]] && source "$HOME/.bashrc.local"
[[ -r "$HOME/.config/bash/conf.d/30-prompt.bash" ]] &&
  source "$HOME/.config/bash/conf.d/30-prompt.bash"
```

Do not link or copy machine-local deployment hooks into the shared repository.

## Prompt

Oh My Posh uses `~/.config/oh-my-posh/atomic.omp.json`, identical to the macOS
configuration: colored segments for shell, path, Git and execution time, a
right-aligned context block, and a second line for command input.

`30-prompt.bash` removes Starship's prompt callbacks after Omarchy loads it,
preserves shared history, and activates Oh My Posh. The installed Oh My Posh
binary manages its own initialization cache.

Set `OMP_THEME=developer` before loading the module to use a different local
theme. Set `OMP_THEME=starship` before starting Bash to use the preserved
`~/.config/starship.toml` configuration instead. Open a new terminal after changes.

## Not ported

- **zsh-autosuggestions / zsh-syntax-highlighting.** No bash equivalent.
  `ble.sh` is the closest and `60-tools.bash` sources it if present.
- **`AUTO_PUSHD`, `HIST_REDUCE_BLANKS`.** No bash equivalent.
- **Ghostty config.** Ghostty isn't installed; foot is. The portable
  preferences (beam cursor + blink, copy-on-select, hide mouse while typing,
  big scrollback) were merged into `~/.config/foot/foot.ini`; the macOS parts
  (cmd keybinds, `macos-titlebar-style`, `macos-icon`) have no counterpart.
  `background-opacity = 0.9` was left out because Omarchy's themes manage
  transparency — add `[colors]` / `alpha=0.9` to foot.ini if you want it.
- **MonoLisa Variable.** Not installed; foot keeps JetBrainsMono Nerd Font.

## Missing tools

`direnv`, `atuin`, `yazi`, `delta`, `go`. Every one is guarded, so
nothing here breaks without them.

## Neovim

Merged into Omarchy's `~/.config/nvim` rather than installed side-by-side under
`NVIM_APPNAME=lazyvim`, so Omarchy's theme hot-reload and OSC52 remote clipboard
keep working. Ported: `web.lua`, `testing.lua`, `claude.lua`, `eye-candy.lua`,
`elixir.lua`, the filetype/indent half of `options.lua`, `stylua.toml`, and the
ten LazyVim extras from `lazyvim.json`. `colorscheme.lua` was not ported —
Omarchy regenerates `lua/plugins/theme.lua` on every `omarchy-theme-set`.

The portable Neovim fixes are included in the shared configuration:

1. **Mason double-install.** LazyVim marks `ensure_installed` with
   `opts_extend`, so lists concatenate without dedup, and its config loop calls
   `pkg:install()` once per entry. `stylua`/`shfmt` (LazyVim base), `erb-lint`
   (lang.ruby) and `prettier` (formatting.prettier) were each listed twice; the
   second call asserts *"Package is already installing"* and aborts mason's
   whole config, so **nothing** installs. Now merged add-if-absent, and LSP
   server packages are left to mason-lspconfig instead of being named twice.
2. **Indent guides drawn three times.** LazyVim ships `snacks.indent` enabled
   and `eye-candy.lua` adds indent-blankline *and* mini.indentscope on top.
   `snacks.indent` is disabled at the top of the ported `eye-candy.lua`.

## Symlinks on this machine

    ~/.config/bash          -> ~/dot-files/bash
    ~/.config/starship.toml -> ~/dot-files/starship/starship.toml
    ~/.config/ripgrep       -> ~/dot-files/ripgrep
    ~/.config/oh-my-posh    -> ~/dot-files/oh-my-posh
    ~/.config/nvim/lua/plugins/{web,testing,claude,eye-candy}.lua
                          -> ~/dot-files/nvim/lua/plugins/...
    ~/.config/nvim/lua/plugins/elixir.lua
                          -> ~/dot-files/omarchy/px13/home/.config/nvim/lua/plugins/elixir.lua
    ~/.config/nvim/stylua.toml
                          -> ~/dot-files/nvim/stylua.toml

The Linux Elixir override assumes the existing LazyVim Elixir extra. It
preserves the Fish and Dockerfile linters. The shared `nvim/lua/plugins/elixir.lua`
continues to configure Expert for macOS; do not replace it with the Linux file.

Not symlinked, because Omarchy owns the file and the port is an appended block:
`~/.bashrc`, `~/.config/nvim/lua/config/options.lua`, `~/.config/nvim/lazyvim.json`,
`~/.config/foot/foot.ini`.

## Backups

`~/.bashrc.bak.20260909` and `~/.config/foot/foot.ini.bak`.
