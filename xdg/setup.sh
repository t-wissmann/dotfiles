#!/bin/bash -e

::() {
    echo -e "\e[1;32m:: \e[1;37m$*\e[0m" >&2
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
    local name="${3:-${1%% *}}"
    cat <<EOF
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Name=$name
Comment=
Exec=$exe
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
    desktop_file="$appdir/${cmd_name}.desktop"
    :: Creating desktop file "$desktop_file"
    desktop_entry "$cmd" "$terminal" > "$desktop_file"
    for mimetype in "$@" ; do
        :: Link "${cmd_name}" '<-' "$mimetype" 
        xdg-mime default "${cmd_name}".desktop "$mimetype"
    done
}

gui_app() { app false "$@" ; }
cli_app() { app true "$@" ; }
default-web-browser() {
    xdg-settings set default-web-browser "$1".desktop
}
default-url-scheme-handler() {
    xdg-settings set default-url-scheme-handler "$1".desktop
}

gui_app qutebrowser \
    x-scheme-handler/{http,https} \
    text/html




