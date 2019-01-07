#!/bin/sh

# define some aliases and helper functions usable in both zsh and bash

mkcd() {
  mkdir "$1" && cd "$1"
}
alias ll='/bin/ls --color=auto -lah'
alias ls='ls -B --color=auto'
alias lln='ls -t -lah --color=always|head'
alias rot13="tr '[A-Za-z]' '[N-ZA-Mn-za-m]'"
alias rot1="tr '[A-Za-z]' '[B-ZAb-za]'"
alias rot25="tr '[B-ZAb-za]' '[A-Za-z]'"
alias urldecode=$'python2 -c "import sys, urllib as ul;\nfor line in sys.stdin: print ul.unquote_plus(line)"'
alias urlencode=$'python2 -c "import sys, urllib as ul;\nfor line in sys.stdin: print ul.quote_plus(line)"'
# fop is broken and always has been a mess...
#alias asciidoc2pdf='JAVA_HOME=/usr/lib/jvm/java-7-openjdk a2x --xsltproc-opts="--stringparam alignment justify" -f pdf --fop -d article -a lang=de'

::() {
    echo -e "\e[1;33m:: \e[0;32m$*\e[0m" >&2
    "$@"
}

asciidoc2pdf() {
    :: asciidoc -b docbook - < "$1" \
        | :: pandoc --from docbook - \
            -V 'geometry:margin=1in' \
            -V papersize:a4 \
            -V lang:de-DE \
            -V toc \
            -o "${1%%.txt}.pdf"
}

asciidoc2md() {
    :: asciidoc -b docbook - < "$1" \
        | :: pandoc --from docbook - \
            -t commonmark \
            -o "${1%%.txt}.md"
}

asciidoc2wiki() {
    :: asciidoc -b docbook - < "$1" \
        | :: pandoc --from docbook - \
            -t mediawiki \
            -o "${1%%.txt}.md"
}

alias ts='~/dotfiles/utils/tmux-reattachloop.sh tmux new-session -A -D -s shell'
alias rm='gio trash'
alias djvu2pdf='ddjvu -format=pdf -quality=85 -verbose'

export GREP_COLOR="1;33"
export GREP_COLORS="mc=1;33"
alias grep='grep --color=auto'

export EDITOR="vim"
export PAGER="less"


setWindowTitle(){
    echo -ne '\033]0;'$1'\007'
}

px() {
    ps aux|grep "$*"
}

# add colors for less when viewing manpages
export LESS_TERMCAP_mb=$'\e[01;31m' # begin blinking - for what is this line good for ?
export LESS_TERMCAP_md=$'\e[1;35m' # begin bold - syntax and keywords
export LESS_TERMCAP_me=$'\e[0m' # end mode - some rows
export LESS_TERMCAP_so=$'\e[0;43;30m' # begin standout-mode -- statusbar and searchhighlights
export LESS_TERMCAP_se=$'\e[0m' # end standout-mode first and last row background
export LESS_TERMCAP_us=$'\e[0;32m' # begin underline "variables"
export LESS_TERMCAP_ue=$'\e[0m'    # end underline background

# for openoffice .... -.-
export OOO_FORCE_DESKTOP='gnome'

export FZF_DEFAULT_OPTS="--tabstop=4 --color=dark,bg+:0,hl+:3,hl:2"
export PASSWORD_STORE_ENABLE_EXTENSIONS="true"

