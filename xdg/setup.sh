#!/bin/bash -e

::() {
    echo -e "\e[1;32m:: \e[1;37m$*\e[0m" >&2
}
warning() {
    echo -e "\e[1;31mWarning: \e[01;33m$*\e[0m" >&2
}


config() {
cat <<EOF
text/
image/
application/pdf
EOF
}

desktop_entry() {
    local exe="$1"
    local terminal="$2"
    prefix=""
    if [ "$terminal" = true ] ; then
        prefix="urxvt -e "
        terminal=false
    fi
    local name="${3:-${1%% *}}"
    cat <<EOF
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Name=$name
Comment=
Exec=$prefix$exe
Icon=
Terminal=$terminal
Type=Application
Categories=
EOF
}

appdir="$HOME/.local/share/applications/"

app() {
    terminal="$1"
    cmd="$2"
    cmd_name="${cmd%% *}"
    shift 2
    desktop_file="$appdir/${cmd_name##*/}.desktop"
    :: Creating desktop file "$desktop_file"
    desktop_entry "$cmd" "$terminal" > "$desktop_file"
    for mimetype in "$@" ; do
        case "$mimetype" in
        /*)
            # mime-types custom for this script
            case "${mimetype#/}" in
                web-browser)
                    :: New default web browser: "${cmd_name}"
                    xdg-settings set default-web-browser "${desktop_file##*/}"
                    ;;
                url-scheme-handler)
                    :: New default url scheme handler: "${cmd_name}"
                    xdg-settings set default-url-scheme-handler "${desktop_file##*/}"
                    ;;
            esac
            ;;
        .*)
            # link silently
            xdg-mime default "${desktop_file##*/}" "${mimetype#.}"
            ;;
        *)
            # ordinary mime-types
            #if ! grep -xm 1 "$mimetype" /usr/share/mime/types > /dev/null ; then
            #    warning "Mimetype $mimetype unknown. Linking anyway."
            #fi
            :: Link "${cmd_name}" '<-' "$mimetype" 
            xdg-mime default "${desktop_file##*/}" "$mimetype"
            ;;
        esac
    done
}

gui_app() { app false "$@" ; }
cli_app() { app true "$@" ; }
mimes() { grep -xE "$1" /usr/share/mime/types | sed 's,^,.,'; }

gui_app qutebrowser \
    x-scheme-handler/{http,https} \
    /default-{web-browser,url-scheme-handler} \
    text/html

cli_app vim \
    $(mimes 'text/.*') \
    text/x-shellscript \
    application/x-shellscript \
    application/ecmascript \
    application/javascript

gui_app katarakt            \
    application/pdf         \
    application/x-bzpdf     \
    application/x-gzpdf     \
    application/x-xzpdf     \
    application/x-pdf       \
    x-unknown/pdf           \
    text/pdf                \

gui_app viewnior            \
    image/{x-,}{tiff,sun-raster} \
    image/{gif,jpeg,png} \
    image/{svg+xml,svg-xml}

# Check your mail-setup with:
# xdg-open 'mailto:p@thorsten-wissmann.de?cc=C1&cc=C2&subject=subject'
gitroot=$(git rev-parse --show-toplevel)
cli_app "$gitroot"/xdg/mutt-mailto.py \
    x-scheme-handler/mailto


