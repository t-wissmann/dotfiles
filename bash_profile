#
# ~/.bash_profile
#

# extend path-variable
if [ -d "${HOME}/.local/bin" ] ; then
    export PATH="${HOME}/.local/bin:${PATH}"
fi
if [ -d "${HOME}/bin" ] ; then
    export PATH="${HOME}/bin:${PATH}"
fi
if [ -d "${HOME}/.cabal/bin" ] ;then
    export PATH="${HOME}/.cabal/bin:${PATH}"
fi

# extend man-variable
if [ -d "${HOME}/man" ] ; then
    export MANPATH="${HOME}/man:${MANPATH}"
fi


[[ -f ~/.bashrc ]] && . ~/.bashrc

# OPAM configuration
#. /home/thorsten/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true

#if [ $(tty) = /dev/tty1 ] && ! which emerge 2> /dev/null > /dev/null ; then
if [ $(tty) = /dev/tty1 ] ; then
	startx -nolisten tcp
	logout
fi

# vim: ft=sh
