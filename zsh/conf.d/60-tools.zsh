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
