
f() {
    cat $1|grep ^require|sort
} 

echo -e "Info:"
echo -e "\e[1;41m > \e[0mmodules missing in local config"
echo -e "\e[1;42m < \e[0mmodules missing in global config"
echo 
echo "Diffs found:"
echo -e "$(diff <(f rc.lua) <(f /etc/xdg/luakit/rc.lua ) |
    grep -E '^[<>]' |
    sed 's/^> /\\e[1;41m > \\e[0m/' |
    sed 's/^< /\\e[1;42m < \\e[0m/' |
    cat
)"

