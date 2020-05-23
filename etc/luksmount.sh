#!/bin/bash -e

# mount a partition that is in a LVM that is in a luks container

::() {
    echo ":: $*" >&2
    "$@"
}

# the actual luks device:
luksDevice=/dev/disk/by-label/sg2020
# the name used for the decrypted thing, i.e. the lvm physical volume:
luksName=sg2020-pv
# the partition in the above lvm to mount:
partition=/dev/mapper/sg2020--vg-sg2020--backup

if [[ -b /dev/mapper/$luksName ]] ; then
    echo "$luksName is already open"
else
    :: cryptsetup luksOpen $luksDevice $luksName
fi
:: vgscan
while sleep 0.3; do
    echo "Waiting for $partition to show up..."
    if [[ -b "$partition" ]] ; then
        break
    fi
done
:: fsck "$partition"
:: mount "$partition"

