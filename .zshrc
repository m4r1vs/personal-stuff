# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

export PATH="/home/marius/.cargo/bin:/home/marius/.local/bin:$PATH"
export PATH="$(ruby -e 'puts Gem.bindir'):$PATH"

source $(dirname $(gem which colorls))/tab_complete.sh

DEFAULT_USER="marius"

# ZSH_THEME="amuse"
ZSH_THEME="powerlevel10k/powerlevel10k"

# CASE_SENSITIVE="true"

# HYPHEN_INSENSITIVE="true"

zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

zstyle ':omz:update' frequency 7

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

setopt AUTO_CD
setopt RM_STAR_WAIT
setopt cdablevarS

DISABLE_UNTRACKED_FILES_DIRTY="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

plugins=(git zsh-autosuggestions zsh-syntax-highlighting command-not-found)

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

alias tt="node /home/marius/Documents/code/personal-stuff/winTerminalToggleColorMode.js"
alias cat="bat"
alias wino="wslview"
alias ports="sudo netstat -tulanp"
alias uhh="ssh 2niveri@rzssh1.informatik.uni-hamburg.de"
alias spotify="spotify-terminal.py -u mariusniveri"
alias cls="/home/marius/.local/share/gem/ruby/3.0.0/gems/colorls-1.4.6/exe/colorls"
alias lc="cls"
alias la="cls -lA --sd"

function chpwd() {
    emulate -L zsh
    cls
}

eval $(thefuck --alias)

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
