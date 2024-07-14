autoload -Uz compinit
compinit
## Powerlevel10k
# Reduce the number of threads for gitstatusd
export GITSTATUS_NUM_THREADS=2
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# https://github.com/zsh-users/zsh-syntax-highlighting/issues/951
# brew install zsh-autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# brew install zsh-syntax-highlighting
# source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# brew install zsh-fast-syntax-highlighting
source $HOMEBREW_PREFIX/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
# brew install zsh-autocomplete 
# source $HOMEBREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh

WORDCHARS='*?_-[]~&;!#$%^(){}<>'
setopt interactive_comments
# History
HISTFILE=$HOME/.zsh_history
SAVEHIST=1000
HISTSIZE=999
setopt SHARE_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_DUPS
setopt HIST_VERIFY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS


# Brew
export HOMEBREW_AUTO_UPDATE_SECS=604800 # 86400 * 7 = week



# # Pyenv
# export PYENV_ROOT="$HOME/.pyenv"
# export PATH="$HOME/.pyenv/bin:$PATH"
# eval "$(pyenv init --path)"
# eval "$(pyenv init -)"
# eval "$(pyenv virtualenv-init -)"
source $HOME/.local/bin/env


# aliases
# docker clear all dangling images
alias docker-clear='docker rmi $(docker images -f "dangling=true" -q)'
alias docker-clear-containers='docker rm $(docker ps -a -f status=exited -f status=created -q)'

alias ls='lsd'
alias la='ls -a'
alias ll='ls -la'
alias lt='ls --tree'
# alias cat='bat'
alias lg='lazygit'
# alias lg='
#     if [[ "$(pwd)" == "/Users/jan.vicha/Projects/work/skippay/core" ]]; then
#         export PYTHONPATH="$PYTHONPATH:$(realpath var/site-packages/):$(realpath dj/libs/)"
#     fi
#     lazygit
# '

alias git-log='git log --pretty=format:"%h - %an, %ar : %s" --graph'
alias git-log-tags="git log --color --no-walk --tags --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias git-remove-merged-branches='git branch --merged | grep -v \* | xargs git branch -D'
alias git-head='git remote show origin | grep 'HEAD branch' | awk '{print $3}''
alias git-ignored='git ls-files -v | grep "^h "'
alias gchb='git checkout -b '
alias gchB='git checkout -B '

alias crypto='/Users/jan.vicha/Projects/personal/CryptoBoard/.venv/bin/python /Users/jan.vicha/Projects/personal/CryptoBoard/app/main.py'

# spruce rust file size utility
alias dud='spruce --sort size -d'

# vscode
alias vscode_l='cp ~/Projects/personal/vscode/settings_laptop.json .vscode/settings.json'
alias vscode_t='cp ~/Projects/personal/vscode/settings_train.json .vscode/settings.json'
alias vscode_big_monitor='cp ~/Projects/personal/vscode/settings_big_monitor.json .vscode/settings.json'

# cursor
alias cs='open -a Cursor'

# zsh
alias zsh-check-all='ps aux | awk '\''/[z]sh/ { if ($3 > 50 || $8=="Z") print }'\'''
alias zsh-kill-all='ps aux | awk '\''/[z]sh/ { if ($3 > 50 || $8=="Z") print $2 }'\'' | xargs kill -9'




  
# skippay core mypy
#export PYTHONPATH=\"$PYTHONPATH:$(realpath var/site-packages/):$(realpath dj/libs/)\"
# if [[ "$(pwd)" == "/Users/jan.vicha/Projects/work/skippay/core" ]]; then
# VENV_SITE_PACKAGES=$(python -c "import site; print(site.getsitepackages()[0])") 
# echo "$(realpath var/site-packages/)" > "$VENV_SITE_PACKAGES/core.pth"
# echo "$(realpath dj/libs/)" > "$VENV_SITE_PACKAGES/libs.pth" 
# fi

# Docker separator https://github.com/docker/compose-switch/issues/24
# export COMPOSE_COMPATIBILITY=tru

# Zoxide (better cd) 
## brew install zoxide
# eval "$(zoxide init zsh)"
# alias cd="z"

# Bind keys
# bindkey "^[[A" history-search-backward
# bindkey "^[[B" history-search-forward
bindkey '\e[1;3C' forward-word

. "$HOME/.local/bin/env"
export PATH="/usr/local/opt/graphviz/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/jan.vicha/.lmstudio/bin"
# End of LM Studio CLI section

eval "$(uv generate-shell-completion zsh)"
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/jan.vicha/gcloud/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/jan.vicha/gcloud/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/jan.vicha/gcloud/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/jan.vicha/gcloud/google-cloud-sdk/completion.zsh.inc'; fi


eval "$(/opt/homebrew/bin/brew shellenv)"
export PATH="/opt/homebrew/bin:$PATH"