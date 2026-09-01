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
