#!/bin/bash

case "$1" in
    monospace)
        fontfamily=terminus
        ;;
    *)
        fontfamily='Bitstream Vera Sans Mono'
        ;;
esac

cat > ~/.config/alacritty/font-overwrite.yml <<EOF
# file created by $0 on $(date)
font:
  normal:
    family: ${fontfamily}
EOF

# force alacrity to reload config
touch ~/.config/alacritty/alacritty.yml
