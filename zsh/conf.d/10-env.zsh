export EDITOR="nvim"
export VISUAL="nvim"

# Neovim loads under the `lazyvim` app-name: config from ~/.config/lazyvim,
# data (including Mason packages) from ~/.local/share/lazyvim. Without this,
# plain `nvim` looks in ~/.local/share/nvim and finds no language servers.
export NVIM_APPNAME="lazyvim"

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export ERL_AFLAGS="-kernel shell_history enabled"
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"
export GOPATH="$HOME/go-workspace"
export CLAUDE_CODE_NO_FLICKER=1
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:200 {}'"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons {}'"
