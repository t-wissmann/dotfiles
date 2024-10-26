#!/usr/bin/env bash

# scanning utility for my home printer...

outfile="$1"
cmdname="$0"
shift

::() {
    echo ":: $*" >&2
    "$@"
}

usage() {
cat <<EOF
Usage: $cmdname TARGETIMAGE [SCANIMAGEARGS]

Scans from to the given TARGETIMAGE and passes the given SCANIMAGEARGS directly
to scanimage.
EOF
}

if [ -z "$outfile" ] ; then
    usage
    exit 1
fi

if [[ "${outfile%.pdf}" != "${outfile}" ]] ; then
    echo "Adjusting output file from PDF to JPG"
    outfile="${outfile%.pdf}.jpg"
fi

while [ -e "$outfile" ] ; do
    # get the last number in the string $outfile,
    # and break otherwise
    number=$(sed 's,^.*\([0-9]\+\)[^0-9]*$,\1,' <<< "$outfile") || break
    if [[ "$number" = "$outfile" ]] ; then
        break
    fi
    # compute +1, but preserve the number of digits
    number_inc=$(printf "%0${#number}d" $((number+1)))
    outfile=$(sed "s,$number\\([^0-9]*\\)$,${number_inc}\\1," <<< "$outfile")
    echo "Incrementing: $number to $number_inc: --> $outfile"
done

# exit 1
# 
# if [ -e "$outfile" ] ; then
#     echo "Warning: $outfile exists already. Override?"
#     read -n 1 -p " yn?" answer
#     if [ ! "$answer" = y ] ; then
#         exit 1
#     fi
# fi

vendor_product_id=04b8:0881

usb_addr=$(:: lsusb -d "$vendor_product_id" \
    |sed 's,^Bus \([^ ]*\) Device \([^ ]*\):.*$,\1:\2,')
sane_device="epkowa:usb:$usb_addr"
#sane_device="epson2:libusb:$usb_addr"
QUALITY=${QUALITY:-81}
MODE=${MODE:-Color} # or Gray

# TODO: do some filtering to avoid noise?
# e.g. add the convert options like: -range-threshold '10%,90%,100%,100%'
# or even -threshold '50%'

:: scanimage -v --mode $MODE -d "$sane_device" --format=tiff \
    | :: convert - -page a4 -quality "${QUALITY}" "$outfile"
