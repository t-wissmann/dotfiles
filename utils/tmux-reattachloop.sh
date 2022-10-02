#!/bin/bash -e


WINDOW_TITLE=""
while [[ -n "$*" ]] ; do
    case "$1" in
        --title=*)
            WINDOW_TITLE="${1#--title=}"
            ;;
        *)
            break
            ;;
    esac
    shift
done

command=( "$@" )

if [ -z "$command" ] ; then
    # defaulting to tmux a
    command=( tmux new-session -A -D -s shell )
fi

if [[ -z "$WINDOW_TITLE" ]] ; then
    WINDOW_TITLE="$HOSTNAME - ${command[*]}"
fi


moon2=(
# source: http://www.ascii-code.com/ascii-art/space/moons.php
"         _.._               "
"       .' .-'\`             "
"      /  /                  "
"      |  |                  "
"      \  \                  "
"       '._'-._              "
"          \`\`\`            "
)

moon1() {
# source: http://www.ascii-code.com/ascii-art/space/moons.php
cat <<EOF
Art by Row
                   .                          +
      +                                                    .
                                ___       .
.                        _.--"~~ __"-.            
                      ,-"     .-~  ~"-\          
         .          .^       /       ( )      . 
               +   {_.---._ /         ~        
                   /    .  Y                   
                  /      \_j                   
   .             Y     ( --l__                 
                 |            "-.              
                 |      (___     \             
         .       |        .)~-.__/             
                 l        _)
.                 \      "l                                
    +              \       \                               
                    \       ^.                             
        .            ^.       "-.                        . 
                       "-._      ~-.___,                   
                 .         "--.._____.^                    
  .                                         .   
EOF
}

message() {
local l='\e[0;37m'
local sec='\e[0;32m'
local val='\e[1;37m'
local key='\e[1;37m'
cat <<EOF
${l}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m
            \033[1;33mSession Detached\e[0m
${l}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m
${sec}Hostname: $val$HOSTNAME
${sec}Command: $val${command[*]}
${sec}Last attached: $val$lastattach
${sec}Keys:\e[0m
    ${key}<Q> ^C  \e[0mQuit
    ${key}Any     \e[0mReattach using the command
${l}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m

Waiting for user input...
EOF
}

recreate_message() {
msg=$(echo -e "$(message)")
msg_trimmed=$(sed $'s,\033\[[^a-zA-Z]*[a-zA-Z],,g' <<< "$msg")
msg_width=$(awk ' { if ( length > x ) { x = length } }END{ print x }' <<< "$msg_trimmed")
msg_lines=$(wc -l <<< "$msg")
}

lastattch='never'
recreate_message

print_msg() {
    clear
    preskip=$((($(tput lines) - msg_lines) / 2))
    indent=$((($(tput cols) - msg_width) / 2))
    if [[ "$indent" -le 0 ]] ; then
        indent=0
    fi
    if [[ "$preskip" -le 0 ]] ; then
        preskip=0
    fi
    prefix=$(printf "%${indent}s" "")
    seq 1 "$preskip" | sed 's,.*,,'
    sed "s,^,$prefix," <<< "$msg" |  awk 'NR>1{print PREV} {PREV=$0} END{printf("%s",$0)}' 
}

setWindowTitle(){
    echo -ne '\033]0;'$1'\007'
}

print_window_title() {
    setWindowTitle "$WINDOW_TITLE"
}

trap 'print_msg' WINCH

while
    "${command[@]}" || true
    lastattach=$(date +'%d. %B %y, %H:%M')
    recreate_message
    print_window_title
    print_msg
    read -s -n 1 input
do
    case "$input" in
        $'\e'|Q|q)
            echo
            echo 'Exiting...'
            break
            ;;
    esac
done

