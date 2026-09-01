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
