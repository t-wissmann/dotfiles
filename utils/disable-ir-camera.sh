#!/usr/bin/env bash

# first run this to see the 'locations' of the usb devices:
# for device in $(ls /sys/bus/usb/devices/*/product); do echo $device;cat $device;done
# and then disable it:
# echo '1-5' | sudo tee /sys/bus/usb/drivers/usb/unbind

for i in /sys/bus/usb/devices/*/product ; do 
	if grep 'Integrated IR Camera' < "$i" > /dev/null ; then
		# get what's in the wildcard
		bus=${i#/sys/bus/usb/devices/}
		bus=${bus%/product}
		if [[ $(id -u) -eq 0 ]] ; then
			echo "tee /sys/bus/usb/drivers/usb/unbind <<< $bus"
			tee /sys/bus/usb/drivers/usb/unbind <<< $bus
		else
			echo "sudo tee /sys/bus/usb/drivers/usb/unbind <<< $bus"
			sudo tee /sys/bus/usb/drivers/usb/unbind <<< $bus
		fi
	fi
done
