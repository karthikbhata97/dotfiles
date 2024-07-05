# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
  export ZSH=/home/an0ne/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"
#ZSH_THEME="agnoster"
# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
export PATH="/usr/local/i386elfgcc/bin:/opt/miniconda/bin:$PATH"
# alias python=python3

mkdcd() {
    mkdir $1 && cd $1
}



# added by Miniconda3 installer
export PATH="/home/an0ne/tools/aflplusplus/bin/:/home/an0ne/tools/riscv/bin/:/home/an0ne/tools/riscv32/bin/:/home/an0ne/miniconda3/bin:/home/an0ne/bin:/home/an0ne/.local/bin:$PATH"
export PATH="/opt/ghidra_9.0:$PATH"
export PATH="/usr/local/go/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"
export GOPATH=$HOME/go
alias python=python3
alias pip=pip3
alias vim=nvim
export EDITOR=/usr/bin/nvim
export PYTHONSTARTUP=/home/an0ne/tools/pystart.py
alias code="/mnt/c/Program\ Files/Microsoft\ VS\ Code/bin/code"
alias docker="/mnt/c/Program\ Files/Docker/Docker/resources/bin/docker"
alias fd=fdfind
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --follow --exclude .git'
export PATH="$PATH:/home/an0ne/sbu/research/dynamorio/DynamoRIO-Linux-9.93.19552/bin64"
alias serve="python -m http.server --bind 127.0.0.1"
export SVF_DIR=/home/an0ne/sbu/research/llvm/SVF
export PATH=$SVF_DIR/Release-build/bin:$PATH
export LLVM_DIR=/home/an0ne/sbu/research/llvm/SVF/llvm-14.0.0.obj
export Z3_DIR=/home/an0ne/sbu/research/llvm/SVF/z3.obj
export PATH="$LLVM_DIR/bin:$PATH"
source ~/.aliases

# opam configuration
test -r /home/an0ne/.opam/opam-init/init.zsh && . /home/an0ne/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true

function rustdoc {
	cd $(dirname `rustup doc --path`)
	explorer index.html
	cd -
}


pipe-to-less() {
    $SHELL -i -c "$(fc -ln -1) | less"
}
zle -N pipe-to-less
bindkey "^[e" pipe-to-less

[ -f "/home/an0ne/.ghcup/env" ] && . "/home/an0ne/.ghcup/env" # ghcup-env