#!/bin/sh

# define some aliases and helper functions usable in both zsh and bash

mkcd() {
  mkdir "$1" && cd "$1"
}
alias beep="echo -e '\\a'"
alias ll='/bin/ls --color=auto -lah'
alias ll='exa -l -a -a'
alias ls='ls -B --color=auto'
alias ls='exa'
alias la='exa -a'
alias l='exa'
#alias cat='bat'
alias lln='ls -t -lah --color=always|head'
alias lln='exa --color=always --sort=modified -a -r -l | head'
alias rot13="tr '[A-Za-z]' '[N-ZA-Mn-za-m]'"
alias rot1="tr '[A-Za-z]' '[B-ZAb-za]'"
alias rot25="tr '[B-ZAb-za]' '[A-Za-z]'"
alias uns='unison -auto srv'
alias urldecode=$'python2 -c "import sys, urllib as ul;\nfor line in sys.stdin: print ul.unquote_plus(line)"'
alias urlencode=$'python2 -c "import sys, urllib as ul;\nfor line in sys.stdin: print ul.quote_plus(line)"'
alias hc=herbstclient
alias 2clipboard='xclip -i -selection clipboard'

alias pdfcrop-lncs='pdfjam --trim "30mm 25mm 30mm 20mm" --suffix cropped'
# fop is broken and always has been a mess...
#alias asciidoc2pdf='JAVA_HOME=/usr/lib/jvm/java-7-openjdk a2x --xsltproc-opts="--stringparam alignment justify" -f pdf --fop -d article -a lang=de'

::() {
    echo -e "\e[1;33m:: \e[0;32m$*\e[0m" >&2
    "$@"
}

asciidoc2pdf() {
    header='
    \DeclareUnicodeCharacter{2009}{~} % fixed with space that appear around -- in asciidoc
    \DeclareUnicodeCharacter{21D2}{\(\Rightarrow\)} % for some reason \ensuremath{} breaks here...
    '
    #\usepackage{newunicodechar}
    #\newunicodechar{⇒}{\ensuremath{\Rightarrow}}
    :: asciidoc -b docbook - < "$1" \
        | :: pandoc --from docbook - \
            --include-in-header=<(echo "$header") \
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

alias myscan='~/dotfiles/utils/scan.sh'
alias myocr='~/dotfiles/utils/ocr'

#export GREP_COLOR="1;33"
export GREP_COLORS="mc=1;33"
alias grep='grep --color=auto'

export EDITOR="vim"
export PAGER="less"
if [[ -x /usr/bin/nvim ]] ; then
    export EDITOR="nvim"
    alias vi=nvim
    alias vim=nvim
fi

alias abook='~/.abook/abook.sh'

setWindowTitle(){
    echo -ne '\033]0;'$1'\007'
}

px() {
    ps aux|grep -i "$*"
}

alias rumutt='mutt -F ~/.mutt/rumuttrc'

# add colors for less when viewing manpages
export LESS_TERMCAP_mb=$'\e[01;31m' # begin blinking - for what is this line good for ?
export LESS_TERMCAP_md=$'\e[1;35m' # begin bold - syntax and keywords
export LESS_TERMCAP_me=$'\e[0m' # end mode - some rows
export LESS_TERMCAP_so=$'\e[0;43;30m' # begin standout-mode -- statusbar and searchhighlights
export LESS_TERMCAP_se=$'\e[0m' # end standout-mode first and last row background
export LESS_TERMCAP_us=$'\e[0;32m' # begin underline "variables"
export LESS_TERMCAP_ue=$'\e[0m'    # end underline background
# since 2023, this also seems to be necessary:
export MANROFFOPT="-P -c"
# export MANPAGER="less -R --use-color"

# for openoffice .... -.-
export OOO_FORCE_DESKTOP='gnome'

export FZF_DEFAULT_OPTS="--tabstop=4 --color=dark,bg+:0,hl+:3,hl:2"
export PASSWORD_STORE_ENABLE_EXTENSIONS="true"

normpages() {
    # count norm pages "normseiten" in a document.
    # one norm page consists of 1500 key strokes
    local strokecount=$(pdftotext -l "${2:-1000000}" "$1" - | wc -m)
    bc -l <<< "$strokecount / 1500"
}

# spellcast now directly supports PDF via pdftotext
# spellcheck-pdf() {
#     wordlist=$HOME/dotfiles/spelling/wordlist.txt 
#     pdftotext -layout "$1" - \
#         | spellcast -- -t --lang=en_GB --variety ize -p "$wordlist" \
#         | less -r
# }

alias dfh="df -h | grep --color=none '^[/A-Z]'"
alias mounth="mount | grep --color=none '^[/A-Z]'"
