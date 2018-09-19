# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000000
SAVEHIST=1000000
setopt appendhistory autocd beep nomatch notify
bindkey -e
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit promptinit
compinit
zstyle ':completion:*' menu select

promptinit
prompt adam2 8bit 'red}%B%F{black' green yellow red

# let small letters match capital letters in a completion suggestion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source ~/dotfiles/shellutils.sh

bindkey    "^[[3~"          delete-char
bindkey    "^[3;5~"         delete-char

alias :r='source ~/.zshrc'
