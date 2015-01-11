#!/bin/bash

monitor="${1:-0}"
height=16
geometry=( $(herbstclient monitor_rect "$monitor") )

print_config() { cat <<EOF
Config { font = "-misc-fixed-*-*-*-*-10-*-*-*-*-*-*-*"
       , bgColor = "#121212"
       , fgColor = "grey"
       , borderColor = "red"
       , position = Static { xpos = ${geometry[0]}
                           , ypos = ${geometry[1]}
                           , width = ${geometry[2]}
                           , height = $height
                           }
       , lowerOnStart = True
       , commands = [ Run Weather "EGPF" ["-t","<station>: <tempC>C","-L","18","-H","25","--normal","green","--high","red","--low","lightblue"] 36000
                    , Run Network "eth0" ["-L","0","-H","32","--normal","green","--high","red"] 10
                    , Run Network "eth1" ["-L","0","-H","32","--normal","green","--high","red"] 10
                    , Run Cpu ["-L","3","-H","50","--normal","green","--high","red"] 10
                    , Run Memory ["-t","Mem: <usedratio>%"] 10
                    , Run Swap [] 10
                    , Run Com "uname" ["-s","-r"] "" 36000
                    , Run Date "%a %b %_d %Y %H:%M:%S" "date" 10
                    ]
       , sepChar = "%"
       , alignSep = "}{"
       , template = "%cpu% | %memory% * %swap% | %eth0% - %eth1% }{ <fc=#ee9a00>%date%</fc>| %EGPF% | %uname%"
       }
EOF
}

#print_config

exec xmobar <(print_config)
