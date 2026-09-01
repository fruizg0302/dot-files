_mise_bin="$HOME/.local/bin/mise"
_mise_cache="$HOME/.cache/mise-activate.zsh"
if [[ -x "$_mise_bin" ]]; then
  if [[ ! -f "$_mise_cache" || "$_mise_bin" -nt "$_mise_cache" ]]; then
    "$_mise_bin" activate zsh > "$_mise_cache"
  fi
  source "$_mise_cache"
fi
unset _mise_bin _mise_cache
