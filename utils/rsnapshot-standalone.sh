#!/usr/bin/env bash

# A script to call rsync with a on-the-fly configuration
# just create a directory in which you want to collect the
# snapshots and place an adjusted version of this file

# the source ssh-remote:
remotedir=user@server:/home/user/Mail

# extra args passed to rsync, e.g. to exclude certain directories
rsyncargs='--exclude=.notmuch,exclude=dovecot-uidlist,exclude=dovecot.index.*'


# the directory in which this script lives:
basedir=$(cd "$(dirname $0)" ; pwd)

rsnapshot.conf() {
cat <<EOF
config_version	1.2
snapshot_root	$basedir
# the following might be important for having hardlinks!
cmd_cp	/usr/bin/cp
cmd_rm	/usr/bin/rm
cmd_rsync	/usr/bin/rsync
cmd_ssh	/usr/bin/ssh
#cmd_logger	/usr/bin/logger
retain	snapshot	80
verbose		4
loglevel	3
lockfile	$basedir/rsnapshot.pid
backup	$remotedir/././	./	+rsync_long_args=$rsyncargs
# do this later to avoid rsync deleting the file
#backup_script	/bin/date "+mail backup started at %c" > log.txt	00LOG/
EOF
}

subcmd=${1:-snapshot}
if [[ "$subcmd" = 'config' ]] ; then
    rsnapshot.conf
else
    exec rsnapshot -c <(rsnapshot.conf) "$subcmd"
fi
