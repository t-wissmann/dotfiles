#!/bin/bash -e

# generate ~/.mpdscribble/mpdscribble.conf based on pass entries
# with the names 'last.fm' and 'libre.fm'

mkdir -p ~/.mpdscribble
chmod 700 ~/.mpdscribble

conf=$HOME/.mpdscribble/mpdscribble.conf

PASSWORD_STORE_DIR=${PASSWORD_STORE_DIR:-$HOME/.password-store}

print_section() {
local name="$1"
local username="$2"
local password="$3"
case "$name" in
    *last.fm*)
        url="http://post.audioscrobbler.com/"
        ;;
    *libre.fm*)
        url="http://turtle.libre.fm/"
        ;;
    *)
        echo "Can not derive url from name \"$name\". Skipping this section." >&2
        return 1
esac
cat <<EOF

[$name]
url = $url
username = $username
password = $password
journal = ~/.mpdscribble/${name//\./}.journal

EOF
}

if [[ -f "$conf" ]] && [[ "$1" != "--force" ]]; then
    echo "$conf already exists. Aborting." 1>&2
    exit 1
fi

pattern='(libre.fm|last.fm).gpg$'

echo "Generating $conf..." >&2
find "$PASSWORD_STORE_DIR" -type f -printf '%P\n' |
    grep -E "$pattern" |
    sort |
while read path ; do
    path="${path%.gpg}"
    name="${path##*/}"
    username=$(pass show "$path" |sed -n '/^user:/I{s,[^:]*:[ ]\?,,i;p;q}')
    password=$(pass show "$path" | head -n 1)
    print_section "$name" "$username" "$password" || continue
done | tee "$conf"


