#!/bin/bash

file="arch-packages"
# Check that all packages specified in `arch-packages` are installed

incomplete_group_installs() {
    # list groups that are not entirely installed
    comm -23 <(pacman -Sgg|sort) <(pacman -Qg|sort)|cut -d' ' -f1|uniq
}

full_group_installs() {
    # list groups that are entirely installed
    comm -23 <(pacman -Sg|sort) <(incomplete_group_installs)
}

# query all packages specified in `arch-packages`
#  - then substract all packages installed
#  - then substract all groups installed
list_missing_packages() {
    grep -vE '^(#|$)' < "$file" | sort \
        | pacman -T \
        | comm -23 - <(full_group_installs)
}

readarray -t not_installed < <(list_missing_packages)

if [ "${#not_installed[@]}" -eq 0 ] ; then
    echo "Everything from $file is installed"
else
    echo "The following ${#not_installed[@]} packages in $file are missing:"
    printf "    %s\n" "${not_installed[@]}"
fi

