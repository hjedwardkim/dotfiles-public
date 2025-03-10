# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -f "/opt/homebrew/bin/brew" ]] then
  # If you're using macOS, you'll want this enabled
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Load completions
setopt prompt_subst
autoload -Uz compinit && compinit
compinit


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -v
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward
bindkey '^e' autosuggest-accept
bindkey '^u' autosuggest-toggle
bindkey '^L' vi-forward-word

# History
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion 
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Aliases
alias ll='eza -alh --icons --color=always --color-scale --group-directories-first --git --time-style=long-iso'
alias lt='eza --tree --level=2 --long --icons --git'
# alias ll='eza -lahr -t=modified'
alias ls='eza'
alias cd='z'
alias python="python3"
alias pip="pip3"
alias awsm='~/aws-scripts/aws-manager.sh'
alias azm='~/az-scripts/az-manager.sh'
alias update-all='brew update && brew upgrade && zinit update && uv tool upgrade --all'
alias aws-login='aws sso login --profile cm-sso'
alias rr='ranger'

alias gct="git log --graph --oneline --all"

# aider stuff
alias aider-auth='gcloud auth application-default login'
alias aider-o3='aider --model azure/o3-mini --reasoning-effort high --edit-format diff'

alias reload-env='load_env'

# ranger
function ranger {
  local IFS=$'\t\n' 
	local tempfile="$(mktemp -t tmp.XXXXXX)"
	local ranger_cmd=(
		command
		ranger
		--cmd="map Q chain shell echo %d > "$tempfile"; quitall"
	)

	${ranger_cmd[@]} "$@"
	if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]]; then
		cd -- "$(cat "$tempfile")" || return
	fi
	command rm -f -- "$tempfile" 2>/dev/null
}

# yazi
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
		builtin cd -- "$cwd"
	fi
	rm -f -- "$tmp"
}

# Aider
load_env() {
    if [ -f /Users/edkim/.apikeys/.env ]; then
        set -a
        source /Users/edkim/.apikeys/.env
        set +a
    else
        echo "Warning: .env file not found at specified location"
    fi
}
load_env

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/edkim/.cache/lm-studio/bin"

# Google cloud
export PATH=$PATH:/opt/homebrew/share/google-cloud-sdk/bin

# Created by `pipx` on 2024-11-26 13:44:14
export PATH="$PATH:/Users/edkim/.local/bin"
