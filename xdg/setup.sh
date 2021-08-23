#!/bin/bash -e

::() {
    echo -e "\e[1;32m:: \e[1;37m$*\e[0m" >&2
    "$@"
}
==() {
    echo -e "\e[1;32m== \e[1;37m$*\e[0m" >&2
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
        prefix="urxvt +hold -e "
        terminal=false
    fi
    local name="${1%% *}"
    mimetypes='' # ;-separated list of mimetypes
    if shift 3 ;then
        for mimetype in "$@" ; do
            case "$mimetype" in
            /*) ;;
            x-unknown/*) ;; # skip those
            .*) mimetypes+="${mimetype#.};"
                ;;
            *) mimetypes+="${mimetype};"
                ;;
            esac
        done
    fi
    cat <<EOF
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Name=${EntryName:-$name}
GenericName=${GenericName}
Comment=
Exec=$prefix$exe$ExecSuffix
Icon=$Icon
Terminal=$terminal
Type=Application
Categories=
MimeType=$mimetypes
EOF
# reset the displayed name
EntryName=""
GenericName=""
Icon=""
ExecSuffix=""
FileName=""
}

appdir="$HOME/.local/share/applications/"
mkdir -p "$appdir"

app() {
    terminal="$1"
    cmd="$2"
    cmd_name="${cmd%% *}"
    shift 2
    local tmp=${cmd_name##*/}
    if [[ "${cmd%%.desktop}" != "${cmd}" ]] ; then
        desktop_file="${cmd}"
        == Using existing desktop file "$desktop_file"
    else
        FileName=${FileName:-${tmp//./}}
        desktop_file="$FileName.desktop"
        == Creating desktop file "$desktop_file"
        # also pass all mimetypes to the desktop entry
        desktop_entry "$cmd" "$terminal" "$@" > "$appdir/$desktop_file"
    fi
    for mimetype in "$@" ; do
        case "$mimetype" in
        /*)
            # mime-types custom for this script
            case "${mimetype#/}" in
                web-browser)
                    == New default web browser: "${cmd_name}"
                    xdg-settings set default-web-browser "${desktop_file}"
                    ;;
                url-scheme-handler)
                    == New default url scheme handler: "${cmd_name}"
                    xdg-settings set default-url-scheme-handler "${desktop_file}"
                    ;;
            esac
            ;;
        .*)
            # link silently
            xdg-mime default "${desktop_file}" "${mimetype#.}"
            ;;
        *)
            # ordinary mime-types
            #if ! grep -xm 1 "$mimetype" /usr/share/mime/types > /dev/null ; then
            #    warning "Mimetype $mimetype unknown. Linking anyway."
            #fi
            == Link "${cmd_name}" '<-' "$mimetype" 
            :: xdg-mime default "${desktop_file}" "$mimetype"
            ;;
        esac
    done
}

gui_app() { app false "$@" ; }
cli_app() { app true "$@" ; }
mimes() { grep -xE "$1" /usr/share/mime/types | sed 's,^,.,'; }

Icon=browser

default_browser=org.qutebrowser.qutebrowser.desktop
for s in \
    x-scheme-handler/{http,https} \
    /default-{web-browser,url-scheme-handler} \
    text/html
do
    :: xdg-mime default "$default_browser" "$s"
done
:: xdg-settings set default-web-browser "$default_browser"

Icon=text-editor
#cli_app vim \
#gui_app emacsclient\ -n\ -c\ --alternate-editor=\ '' \
for s in \
    $(mimes 'text/.*'|grep -v '^\.'| grep -vE 'text/html') \
    text/x-shellscript \
    text/x-c \
    application/x-shellscript \
    application/ecmascript \
    application/csv \
    application/javascript
do
    :: xdg-mime default "gvim.desktop" "$s"
done

Icon=x-office-document
gui_app org.gnome.Evince.desktop \
    application/{,x-bz,x-gz,x-xz,x-}pdf \
    x-unknown/pdf \
    text/pdf

gui_app org.gnome.Evince.desktop application/postscript

Icon=x-office-document
#gui_app evince            \
#    application/postscript

# EntryName="SXIV"
# Icon=emblem-photos
# gui_app ~/dotfiles/utils/sxiv-helper.sh \
#     image/{x-,}{tiff,sun-raster} \
#     image/{gif,jpeg,png} \
#     image/{svg+xml,svg-xml}
Icon=emblem-photos
gui_app viewnior \
    image/{x-,}{tiff,sun-raster} \
    image/{gif,jpeg,png,ppm,pbm} \
    image/{svg+xml,svg-xml}

EntryName="MPV (Append)"
Icon=applications-multimedia
gui_app ~/dotfiles/utils/mpv-append.sh \
    $(mimes 'video/.*') \
    $(mimes 'audio/.*')

FileName="skype-web-chromium"
EntryName="Skype Web (in Chromium)"
gui_app "chromium --incognito https://web.skype.com"
xdg-mime default Thunar-folder-handler.desktop inode/directory

xdg-mime default libreoffice-base.desktop \
    application/vnd.oasis.opendocument.text

# Check your mail-setup with:
# xdg-open 'mailto:test@example.de?cc=C1&cc=C2&subject=subject'
gitroot=$(git rev-parse --show-toplevel)
EntryName="Mutt"
Icon=mail_generic
ExecSuffix=" %u"
cli_app "$gitroot"/xdg/mutt-mailto.py \
    x-scheme-handler/mailto

# install local desktop files
targetdir=$HOME/.local/share/applications/
for i in *.desktop ; do
    if [[ -L "$targetdir/$i" ]] ; then
        == "$targetdir/$i" already exists
        continue
    fi
    :: ln -s "`pwd`/$i" "$targetdir"
done
:: update-desktop-database "$targetdir"

