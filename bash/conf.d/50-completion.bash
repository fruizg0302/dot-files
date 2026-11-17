# Ported from zsh/conf.d/50-completion.zsh.
#
# Most of the zsh zstyles already have an Omarchy equivalent, so this file only
# adds what's missing:
#   compinit + cache-path      -> bash-completion, sourced by default/bash/shell
#   menu select                -> `TAB: menu-complete` in default/bash/inputrc
#   matcher-list (ignore case) -> `set completion-ignore-case on`, same file
#   list-colors                -> `set colored-stats on`, same file
[[ $- == *i* ]] || return

# Treat - and _ as interchangeable while completing (zsh's matcher-list also
# smoothed over this; readline needs it asked for explicitly).
bind 'set completion-map-case on' 2>/dev/null

# User-installed completions. bash-completion picks these up lazily; sourcing
# any strays here keeps hand-dropped files working too.
if [[ -d $HOME/.local/share/bash-completion/completions ]]; then
  for _c in "$HOME"/.local/share/bash-completion/completions/*; do
    [[ -r $_c ]] && source "$_c"
  done
  unset _c
fi
