# Ported from zsh/conf.d/20-path.zsh. bash has no `typeset -U path`, so each
# entry is added only if it isn't already present and the directory exists.
_path_prepend() { [[ -d $1 && ":$PATH:" != *":$1:"* ]] && PATH="$1:$PATH"; }
_path_append()  { [[ -d $1 && ":$PATH:" != *":$1:"* ]] && PATH="$PATH:$1"; }

_path_prepend "$GOPATH/bin"
_path_prepend "$HOME/.local/bin"
# Dropped: /opt/homebrew/opt/libpq/bin (macOS only).

# Appended, not prepended, so project binstubs and `bundle exec` win over
# Neovim's Mason-managed tools (ruby-lsp, rubocop, prettier, eslint_d, ...).
# ~/.local/share/nvim, not .../lazyvim: no NVIM_APPNAME on this machine.
_path_append "$HOME/.local/share/nvim/mason/bin"

# LM Studio CLI (lms). Was appended raw to ~/.bashrc and ~/.bash_profile by the
# installer, which duplicated it in PATH; the helper skips it when absent.
_path_append "$HOME/.lmstudio/bin"

unset -f _path_prepend _path_append
export PATH
