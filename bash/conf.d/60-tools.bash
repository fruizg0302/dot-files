# Ported from zsh/conf.d/60-tools.zsh. Every tool stays independently guarded,
# so a partially-provisioned machine still boots a working shell.

# Caches a tool's shell-init output and re-generates it when the binary is newer.
_cached_init() {
  command -v "$1" >/dev/null 2>&1 || return 0
  local tool="$1" cache="$HOME/.cache/bash-init-$1.bash" bin
  bin="$(command -v "$tool")"
  [[ -f $cache && ! $bin -nt $cache ]] || "$@" >"$cache" 2>/dev/null
  source "$cache"
}

# fzf: Omarchy already sources /usr/share/fzf/{completion,key-bindings}.bash
# from default/bash/init, so ctrl-t / ctrl-r / alt-c are live. The FZF_*
# variables in 10-env.bash are what actually shape them.

# mise and zoxide are likewise activated by Omarchy's default/bash/init
# (this replaces zsh/conf.d/70-mise.zsh entirely).

_cached_init direnv hook bash

# atuin needs bash-preexec on bash; both are installed together by
# `sudo pacman -S atuin` + the bash-preexec shim it ships.
if command -v atuin >/dev/null 2>&1; then
  [[ -r /usr/share/bash-preexec/bash-preexec.sh ]] && source /usr/share/bash-preexec/bash-preexec.sh
  # Up-arrow is left to readline's history-search (Omarchy's inputrc binds it);
  # atuin only takes ctrl-r, matching the zsh config.
  _cached_init atuin init bash --disable-up-arrow
fi

# zsh-autosuggestions / zsh-syntax-highlighting have no drop-in bash twin.
# The closest is ble.sh (`yay -S blesh-git`), which provides both plus the
# tab-completes-or-accepts-suggestion behaviour bound in the zsh config.
# Sourced here if present; nothing breaks when it isn't.
if [[ $- == *i* && -r $HOME/.local/share/blesh/ble.sh ]]; then
  source "$HOME/.local/share/blesh/ble.sh" --noattach
  bleopt complete_auto_complete=1
  ble-attach
fi
