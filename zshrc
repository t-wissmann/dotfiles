# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000000
SAVEHIST=1000000

setopt HIST_IGNORE_SPACE  # don't put commands with space in history

setopt appendhistory autocd beep nomatch notify
setopt interactivecomments
bindkey -e
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit promptinit vcs_info
compinit
zstyle ':completion:*' menu select

promptinit
prompt adam2 8bit 'red}%F{white' green yellow default


paste-prompt() {
    # setup a prompt that is nicer for copy & pasting terminal content
    prompt restore
    PS1='%F{green}%~%F{blue}> %f'
    # disable prompt command
    precmd() {
        true
    }
    RPROMPT=''
}

# let small letters match capital letters in a completion suggestion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

zstyle ':vcs_info:git:*' formats '%b'


source ~/dotfiles/shellutils.sh

trysource() {
    if [[ -f "$1" ]] ; then
        source "$1"
    fi
}
trysource /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
trysource /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

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
bindkey \^U backward-kill-line

# let 'delete word' stop at slashes: https://unix.stackexchange.com/a/250700/156880
my-backward-delete-word() {
    local WORDCHARS=${WORDCHARS/\//}
    zle backward-delete-word
}
zle -N my-backward-delete-word
bindkey '^W' my-backward-delete-word

autoload -Uz add-zsh-hook

function xterm_title_precmd () {
    if [[ "$TERM" == (screen*|xterm*|rxvt*) ]]; then
        print -Pn '\e]2;%1~ %n@%m\a'
    fi
}

alias -g G="| grep -iE"
alias -g L=" 2>&1 | less -R"
alias -g C=" --color=always"

#zstyle ':completion:*:*:kill:*' menu yes select
#zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
#zstyle ':completion:*:*:kill:*:processes' command 'ps xo pid,user:10,cmd | ack-grep -v "sshd:|-zsh$"'
#zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"

# add running command to title
#function xterm_title_preexec () {
#	print -Pn '\e]2;%n@%m %1~ %# '
#	print -n "${(q)1}\a"
#}

add-zsh-hook -Uz precmd xterm_title_precmd
#add-zsh-hook -Uz preexec xterm_title_preexec

preexec() {
  timer=${timer:-$SECONDS}
  if [[ "$TERM" == (screen*|xterm*|rxvt*) ]]; then
      # do not add -P here. otherwise $( ) within ${2} will be expanded!
      #
      # $ print -P 'foo $(echo bar) baz'
      # foo bar baz
      #
      title=${2}
      title=${title//\\/\\\\}
      print -n '\e]2;'"${title}"
      print -Pn ' (%1~) %n@%m\a'
      true
  fi
}

precmd() {
  myprompt=''
  if [ $timer ]; then
    timer_show=$(($SECONDS - $timer))
    if [ ${timer_show} -eq 0 ] ; then
        unset timer
    else
        #timer_show=400000 # for testing
        timer_suffix='s'
        # alternate versions for the unit:
        #   m,60 h,60 d,24 w,7
        #   m,60 h,60 d,24 year,365 century,100
        for unit in m,60 h,60 d,24 ; do
            size=${unit#*,}
            name=${unit%,*}
            if [[ ${timer_show} -ge ${size} ]] ; then
                timer_suffix="${name} $((timer_show % ${size}))$timer_suffix"
                timer_show=$((timer_show / ${size}))
            else
                break
            fi
        done
        myprompt+="%F{cyan}${timer_show}${timer_suffix}%{$reset_color%}"
        unset timer
    fi
  fi
  vcs_info
  myprompt+=" %F{blue}${vcs_info_msg_0_}"
  export RPROMPT="${myprompt}"
}

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

trysource ~/.zshrc-host-specific
trysource /usr/share/fzf/key-bindings.zsh
trysource /usr/share/fzf/completion.zsh

# Always trigger the fzf completion routine
export FZF_COMPLETION_TRIGGER=''
# However, the fzf completion routine falls back to
# dir and path based completion, even if more advanced
# completion systems in zsh are available. For those cases
# I overwrite dir/path completion such that the usual zsh
# completion is called.
_fzf_dir_completion() {
    zle ${fzf_default_completion:-expand-or-complete}
}
_fzf_path_completion() {
    zle ${fzf_default_completion:-expand-or-complete}
}

#bindkey -v # vi mode

# opam configuration
[[ ! -r ~/.opam/opam-init/init.zsh ]] || source ~/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null


