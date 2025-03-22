# Zsh Plugin Manager -> zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# General Zsh Config
HISTFILE=$HOME/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# Zsh plugins
zinit load zdharma-continuum/history-search-multi-word
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light jeffreytse/zsh-vi-mode

# Env Variables
export EDITOR='nvim'
export TERMINAL='kitty'
export TERM='xterm-kitty'
export OPENAI_API_KEY='sk-3ab5a52ea62944faaa4485461f43a03d'

# My alias
alias c="clear"
alias ls="lsd"
alias vim="nvim"

# My Configurations 
# source ~/.config/clash/clash-api.sh
source ~/.config/clash/mihomo-api.sh

# Update pacman mirror list
function update_pacmirror() {
  sudo reflector --latest 10 --sort rate --protocol https --country China | sudo tee /etc/pacman.d/mirrorlist
}

# Hardware Control for XiaoXinPro
source ~/.config/i3/sysmod.sh
source ~/.config/i3/batctl.sh

# Change dpi
source ~/.config/i3/dpi-setter.sh

# Fzf 
source <(fzf --zsh)

# Yazi
# y shell wrapper that provides the ability to change the current working directory when exiting Yazi.
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Starship prompt
eval "$(starship init zsh)"

# Pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Zoxide
eval "$(zoxide init zsh)"

# thefuck
eval $(thefuck --alias)
