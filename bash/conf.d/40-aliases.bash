# Ported from zsh/conf.d/40-aliases.zsh. Safe for scripts and agents alike —
# display-changing aliases live in 41-interactive.bash.

: "${WORKSPACE:=$HOME/workspace}"

# A function so it can explain itself: when WORKSPACE is a symlink into an
# unmounted volume, a bare "no such file or directory" hides the cause.
wks() {
  if [[ ! -d $WORKSPACE ]]; then
    printf 'wks: WORKSPACE does not resolve: %s\n' "$WORKSPACE" >&2
    if [[ -L $WORKSPACE ]]; then
      printf 'wks: dangling symlink -> %s — volume not mounted?\n' "$(readlink "$WORKSPACE")" >&2
    fi
    return 1
  fi
  builtin cd "$WORKSPACE"
}

alias dc='docker compose'
alias dps='docker compose ps'
alias dl='docker logs -f'
alias dex='docker exec -it'
alias dstat='docker stats --no-stream'
alias docker-clean='docker system prune -af --volumes'

# Omarchy defines ga()/gd() as git-worktree helpers (default/bash/fns/worktrees)
# and `ga` collides with `git add`. Keep both: the worktree helpers move to
# gwa/gwd, the alias takes the short name. Delete this block to hand `ga` back.
if declare -F ga >/dev/null && ! declare -F gwa >/dev/null; then
  eval "gwa() $(declare -f ga | tail -n +2)"
  declare -F gd >/dev/null && eval "gwd() $(declare -f gd | tail -n +2)"
fi

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
