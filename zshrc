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
prompt adam2 8bit 'red}%B%F{black' green yellow default

# let small letters match capital letters in a completion suggestion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

source ~/dotfiles/shellutils.sh

bindkey    "^[[3~"          delete-char
bindkey    "^[3;5~"         delete-char
#bindkey -s '\eu' '^Ucd ..^M' # Meta-u to chdir to the parent directory
#bindkey -s '^[^[[A' '^E^Ucd ..^M' # Alt-↑ to chdir to the parent directory

alias :r='source ~/.zshrc'

cdUndoKey() {
  popd || return 0
  #zle       reset-prompt
  #echo
  #ls
  zle       reset-prompt
  xterm_title_precmd
}

cdParentKey() {
  pushd ..
  zle      reset-prompt
  #echo
  #ls
  #zle       reset-prompt
  xterm_title_precmd
}

zle -N                 cdParentKey
zle -N                 cdUndoKey
bindkey '^[[1;3A'      cdParentKey
bindkey '^[[1;3D'      cdUndoKey
bindkey '^[^[[A'      cdParentKey
bindkey '^[^[[D'      cdUndoKey

autoload -Uz add-zsh-hook

function xterm_title_precmd () {
    if [[ "$TERM" == (screen*|xterm*|rxvt*) ]]; then
        print -Pn '\e]2;%n@%m %1~\a'
    fi
}

# add running command to title
#function xterm_title_preexec () {
#	print -Pn '\e]2;%n@%m %1~ %# '
#	print -n "${(q)1}\a"
#}

add-zsh-hook -Uz precmd xterm_title_precmd
#add-zsh-hook -Uz preexec xterm_title_preexec

