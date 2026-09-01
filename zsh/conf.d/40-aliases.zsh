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
