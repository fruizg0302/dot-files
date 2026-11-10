# Ported from zsh/conf.d/41-interactive.zsh.
#
# Human-only. Claude Code snapshots the interactive shell and exports
# CLAUDECODE; bat's line numbers would corrupt its `cat a > b` redirects and
# eza prints nothing there when run without a path.
[[ $- == *i* && -z $CLAUDECODE ]] || return

# These override Omarchy's own eza aliases (ls/lsa/lt/lta) on purpose.
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first --git'
alias tree='eza --tree --icons'
# `-n` shows line numbers; `--plain` would cancel it. `--paging=never` keeps
# pipes and redirects clean.
alias cat='bat -n --paging=never'
alias less='bat --paging=always'

# yazi is not installed here (`sudo pacman -S yazi`); guarded so the shell
# still boots clean, exactly like the tools in 60-tools.bash.
if command -v yazi >/dev/null 2>&1; then
  y() {
    local tmp cwd
    tmp="$(mktemp -t yazi-cwd.XXXXXX)"
    yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd <"$tmp"
    [[ -n $cwd && $cwd != "$PWD" ]] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
  }
fi
