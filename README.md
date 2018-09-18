# Some dotfiles



## Snippets

Add mp3gain to all mp3 files in the current directory and child directories, treating every directory as an album:
```
find -mindepth 2 -type f -iname '*.mp3' | sed 's,/[^/]*$,,' | sort | uniq| while read -r dir ; do echo mp3gain -p "$dir"/*.[Mm][Pp]3 ; done
```

Add replaygain to all flac files in the current directory and child
directories, treating every directory as an album. if at least one replaygain
tag is set in one of the files, the entire directory is skipped. Also do things in parallel:
```
gain_dir() {
    [[ -n "$(metaflac --show-tag=REPLAYGAIN_TRACK_GAIN "$1"/*.[Ff][Ll][Aa][Cc])" ]] && return 0
    echo metaflac --add-replay-gain --preserve-modtime "$1"/*.[Ff][Ll][Aa][Cc]
}
export -f gain_dir
find -mindepth 2 -type f -iname '*.flac' | sed 's,/[^/]*$,,' | sort | uniq| parallel gain_dir '{}'
```

