#
# ~/.zprofile
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
if [ -d "${HOME}/dotfiles/utils" ] ;then
    export PATH="${PATH}:${HOME}/dotfiles/utils"
fi

# extend man-variable
if [ -d "${HOME}/man" ] ; then
    export MANPATH="${HOME}/man:${MANPATH}"
fi


# OPAM configuration
#. /home/thorsten/.opam/opam-init/init.sh > /dev/null 2> /dev/null || true

#if [ $(tty) = /dev/tty1 ] && ! which emerge 2> /dev/null > /dev/null ; then
if [ $(tty) = /dev/tty1 ] ; then
	startx -nolisten tcp
	logout
fi

