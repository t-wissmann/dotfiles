#!/bin/bash

# Check for an interactive session
[ -z "$PS1" ] && [ "$1" != "FORCE" ] && return

# the most important alias due to vi/vim migration on archlinux
alias vi=vim


shopt -s checkwinsize


function trysource() {
    [ -f "$1" ] && source "$1"
}
# include some aliases and functions
trysource ~/.bash.d/exports
trysource ~/.bash.d/aliases
trysource ~/.bash.d/functions

#[ -f ~/scripts/shcollection/src/bash_functions ] &&
#    source ~/scripts/shcollection/src/bash_functions


# really load private data...
# its dangerous ;)
trysource ~/.bash_private

#load some settings
if [ -f "$HOME/.bash.d/settings.$(hostname)" ] ; then
    trysource "$HOME/.bash.d/settings.$(hostname)"
else
    trysource ~/.bash.d/settings
fi

_userland()
{
    local userland=$( uname -s )
    [[ $userland == @(Linux|GNU/*) ]] && userland=GNU
    [[ $userland == $1 ]]
}

#trysource /usr/share/bash-completion/bash_completion
#trysource /etc/bash_completion
for i in git mpc netctl systemctl ; do
    trysource /etc/bash_completion.d/$i
    trysource /usr/share/bash-completion/completions/$i
done

trysource ~/dev/c/herbstluftwm/share/herbstclient-completion
trysource ~/git/herbstluftwm/share/herbstclient-completion

case `hostname` in
    faui0*) trysource ~/.bash.d/cip ;;
    ircbox) trysource ~/.bash.d/cip ;;
    mephisto) trysource ~/.bash.d/mephisto ;;
esac

#LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=01;31:*.tgz=01;31:*.svgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.flv=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:'
#export LS_COLORS


#trap 'echo -ne "\e]0;$BASH_COMMAND\007"' DEBUG
