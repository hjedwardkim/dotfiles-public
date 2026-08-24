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
# alias cd='z'
alias python="python3"
alias pip="pip3"
alias awsm='~/aws-scripts/aws-manager.sh'
alias azm='~/az-scripts/az-manager.sh'
safe-brew-upgrade() {
  local cutoff=$(date -v-1d +%s)
  local tap=$(brew --repository homebrew/core 2>/dev/null)
  if [[ -z "$tap" || ! -d "$tap" ]]; then
    echo "[timegate] homebrew-core tap not found, running normal upgrade"
    brew upgrade; return
  fi
  local outdated=$(brew outdated --quiet)
  [[ -z "$outdated" ]] && return
  local safe=() skipped=()
  while IFS= read -r pkg; do
    local rb="$tap/Formula/${pkg:0:1}/${pkg}.rb"
    local ts=$(git -C "$tap" log -1 --format=%at -- "$rb" 2>/dev/null)
    if [[ -z "$ts" ]] || (( ts < cutoff )); then
      safe+=("$pkg")
    else
      skipped+=("$pkg")
    fi
  done <<< "$outdated"
  (( ${#skipped[@]} )) && echo "[timegate] skipping (updated <1d ago): ${skipped[*]}"
  (( ${#safe[@]} )) && brew upgrade "${safe[@]}"
}
alias update-all='brew update && safe-brew-upgrade && zinit update && uv tool upgrade --all --exclude-newer $(date -v-1d +%Y-%m-%dT%H:%M:%SZ) && claude update && npm i -g @openai/codex && pi update && opencode upgrade && omp update && herdr update'
alias update-dev='claude update && npm i -g @openai/codex && pi update && pi update && opencode upgrade && omp update && herdr update'
alias rr='ranger'

alias gct="git log --graph --oneline --all"

alias reload-env='load_env'

# alias claude='claude --effort xhigh'

# cm localdev iteration loop (Apple Silicon: --platforms linux/amd64 forces amd64 builds)
alias cm-localenv-sync='cm build --branch-diff --platforms linux/amd64 && cm push --branch-diff --platforms linux/amd64 && cm gitops-sync && cm-localenv-import'
alias cm-localenv-argo='git add -A && git commit -m $(date +"%d-%m:%H%M")'
# ArgoCD UI: https://argocd.cmind.local (user admin)
alias cm-localenv-pw='kubectl --context k3d-cmind-local -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo'

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

# nvm
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Shell integrations
eval "$(fzf --zsh)"
if [[ "$CLAUDECODE" != "1" ]]; then
  eval "$(zoxide init --cmd cd zsh)"
fi

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/edkim/.cache/lm-studio/bin"

# Google cloud
export PATH=$PATH:/opt/homebrew/share/google-cloud-sdk/bin

# Created by `pipx` on 2024-11-26 13:44:14
export PATH="$PATH:/Users/edkim/.local/bin"

# Go bin
export PATH="$(go env GOPATH)/bin:$PATH"

# orbstack shenanigans
export DOCKER_HOST=unix:///Users/$USER/.orbstack/run/docker.sock

export PATH="/opt/homebrew/opt/postgresql@18/bin:$PATH"

# Codex external editor
export VISUAL="code --wait"

# Import the amd64 images cm gitops-sync just referenced into k3d (--mode direct).
# Per image, in order: local <hash>-linuxamd64 > bare hash already on host > amd64 pull from ACR.
# Use after: cm build && cm push && cm gitops-sync (on Apple Silicon k3d).
cm-localenv-import() {
  local gitops="${1:-$HOME/dev/platform-gitops}"
  local cluster="${2:-cmind-local}"

  # ACR-authed docker config, built once and reused for images that need a pull.
  local docker_cfg=""
  local _u _p
  _u=$(yq '.acr_token_name' "$HOME/.config/cmctl/config.yml" 2>/dev/null)
  _p=$(yq '.acr_token_password' "$HOME/.config/cmctl/config.yml" 2>/dev/null)
  if [ -n "$_u" ] && [ "$_u" != "null" ] && [ -n "$_p" ] && [ "$_p" != "null" ]; then
    docker_cfg=$(mktemp -d)
    jq -n --arg u "$_u" --arg p "$_p" \
      '{auths:{"confidentialmind.azurecr.io":{username:$u,password:$p}}}' > "$docker_cfg/config.json"
  fi

  # Image refs gitops-sync added. Falls back to the last commit so this still finds them
  # when the bump was already committed (cm-localenv-argo).
  local re='confidentialmind\.azurecr\.io/main/[a-z0-9-]+:[a-f0-9]+'
  local imgs
  imgs=$(git -C "$gitops" diff | grep -E '^\+' | grep -oE "$re" | sort -u)
  if [ -z "$imgs" ]; then
    imgs=$(git -C "$gitops" diff HEAD~1 2>/dev/null | grep -E '^\+' | grep -oE "$re" | sort -u)
    [ -n "$imgs" ] && echo "note: working tree clean, using image refs from the last gitops commit"
  fi
  if [ -z "$imgs" ]; then
    echo "no image refs found in $gitops (working tree or last commit) - nothing to import"
    [ -n "$docker_cfg" ] && rm -rf "$docker_cfg"
    return 0
  fi

  local n_ok=0 n_fail=0
  local img local_img
  while read -r img; do
    [ -z "$img" ] && continue
    local_img="${img}-linuxamd64"
    if docker image inspect "$local_img" >/dev/null 2>&1; then
      docker tag "$local_img" "$img"
      echo "retag  $img (local -linuxamd64)"
    elif docker image inspect "$img" >/dev/null 2>&1; then
      echo "import $img (already on host)"
    elif [ -n "$docker_cfg" ]; then
      echo "pull   $img (amd64 from ACR)"
      if ! DOCKER_DEFAULT_PLATFORM=linux/amd64 docker --config "$docker_cfg" pull --platform linux/amd64 "$img" >/dev/null; then
        echo "  FAIL: ACR pull failed (missing from ACR?) — build it: cm build -w <svc> --platforms linux/amd64"
        n_fail=$((n_fail + 1))
        continue
      fi
    else
      echo "skip   $img (no local build; need yq+jq and ACR creds in ~/.config/cmctl/config.yml)"
      n_fail=$((n_fail + 1))
      continue
    fi
    if k3d image import -c "$cluster" --mode direct "$img" >/dev/null 2>&1; then
      echo "  -> imported into $cluster"
      n_ok=$((n_ok + 1))
    else
      echo "  -> IMPORT FAILED"
      n_fail=$((n_fail + 1))
    fi
  done <<< "$imgs"

  [ -n "$docker_cfg" ] && rm -rf "$docker_cfg"
  echo "done: $n_ok imported, $n_fail failed"
  [ "$n_fail" -eq 0 ]
}
