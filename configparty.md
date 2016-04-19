# Config Party

This file lists highlights of the present `dotfiles` repository which are worth
presenting

  - [nopaste](utils/nopaste) including colored pastes
  - tmux screenshot
    ```
    ssh uber bash -l <<< 'tmux capture-pane -p -e' | nopaste -c
    ```
  - mutt:  reprocess current message with procmail
    ```
    macro index,pager P "\
        <enter-command>set my_pipe_decode=$pipe_decode<enter>\
        <enter-command>set pipe_decode=no<enter>\
        <pipe-entry>procmail<enter>\
        <enter-command>set pipe_decode=$my_pipe_decode<enter>"
    ```
  - [mkmandir.sh](mkmandir.sh) for having a man directory in your home file
  - git-latexdiff
  - mpv single instance
  - coverfetch
  - sxiv, sxiv filter, sxiv-helper.sh
  - dmenu, rofi
    * rofi-netctl
    * rofi-mpd.sh
    * utf8select.sh


// vim: ft=asciidoc
