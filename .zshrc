# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

alias python="python3"
open() {
    nohup nautilus "$@" > /dev/null 2>&1 &!
}

alias lg="lazygit"
alias c="claude"
alias cc="claude --continue"
alias cr="claude --resume"
alias cl="clear"
alias nv="nvim"
alias kd="git kdt" # kitten diff
alias gs="git status"
alias gf="git fetch"
alias gl="git log"
alias gll="git log --oneline"
alias cdd="cd ~/repos/datamasque"
alias cda="cd ~/repos/datamasque-automation"
[[ -f ~/.dm_zshrc ]] && source ~/.dm_zshrc


# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export XDG_DATA_DIRS="$HOME/.local/share:$XDG_DATA_DIRS"

# Kitty
export PATH="$HOME/.local/kitty.app/bin:$PATH"

# Prompt character
export PS1="~ "

# editors
export VISUAL="nvim"
export EDITOR="nvim"

# fix compdef error
autoload -Uz compinit && compinit

# Enable Vi mode in zsh - run brew install zsh-vi-mode
source $(brew --prefix)/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
ZVM_SYSTEM_CLIPBOARD_ENABLED=true

# Trim leading/trailing whitespace before pushing yanks to system clipboard
function zvm_clipboard_copy_buffer() {
  $ZVM_SYSTEM_CLIPBOARD_ENABLED || return
  zvm_clipboard_available || return
  local trimmed=$CUTBUFFER
  trimmed="${trimmed#"${trimmed%%[![:space:]]*}"}"
  trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
  print -rn -- "$trimmed" | eval "$ZVM_CLIPBOARD_COPY_CMD" >/dev/null 2>&1
}

# Terminal theme
source $(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme

# autosuggestions -- install by running: brew install zsh-autosuggestions
source /home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax highlighting -- install by running: brew install zsh-syntax-highlighting
source /home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# History setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt inc_append_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify
# Arrow-key history navigation:
# - empty buffer        -> walks history one entry per press
# - typed prefix        -> walks history filtered by that prefix
# - multi-line buffer   -> moves cursor up/down within the buffer first
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# Wrapped in zvm_after_init so zsh-vi-mode doesn't overwrite these on lazy init.
function zvm_after_init() {
  bindkey -M viins "^[[A" up-line-or-beginning-search
  bindkey -M viins "^[[B" down-line-or-beginning-search
}


# silence homebrew
HOMEBREW_NO_AUTO_UPDATE=1



# Powerlevel10k
source /home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme brew

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH="$HOME/.local/bin:$PATH"
eval "$(uv generate-shell-completion zsh)"

export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"



# yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

fpath+=~/.zfunc; autoload -Uz compinit; compinit

zstyle ':completion:*' menu select
