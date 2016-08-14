#!/bin/bash -e
# set up an task warrior client to sync with the taskd.
# this is basically the description from
# https://taskwarrior.org/docs/taskserver/taskwarrior.html

::() {
    echo ":: $*" >&2
    "$@"
}

userkeyname=thorsten_wissmann
mkdir -p ~/.task
:: scp \
    uber:~/taskd/$userkeyname.{cert,key}.pem \
    uber:~/taskd/ca.cert.pem \
    ~/.task

:: task config taskd.certificate -- ~/.task/$userkeyname.cert.pem
:: task config taskd.key         -- ~/.task/$userkeyname.key.pem
:: task config taskd.ca          -- ~/.task/ca.cert.pem

server=$(ssh uber  'cat ~/taskd/config |grep ^server= |cut -d= -f2-')
:: task config taskd.server      -- "$server"

# import the user
for c in $( ssh uber 'find ~/taskd/orgs -name config -printf "%P\n"') ; do
    org="${c%%/*}"
    id="${c#*/*/}"
    id="${id%/*}"
    fullname=$(ssh uber "grep ^user= ~/taskd/orgs/$c"|cut -d= -f2-)
    echo "Set the users credentials via:"
    echo "task config taskd.credentials -- \"$org/$fullname/$id\""
done


