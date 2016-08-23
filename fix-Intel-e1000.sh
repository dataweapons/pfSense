#!/bin/bash
#
# from Paul M on support@
# see http://doc.pfsense.org/index.php/Intel_e1000_power_save
#
if [ -z "$1" ]; then
	echo "Usage: $0 \<interface\>"
	echo "       i.e. $0 eth0"
	exit 1
fi

if ! ifconfig $1 > /dev/null; then
	exit 1
fi

dev=$(ethtool -e $1 | grep 0x0010 | awk '{print "0x"$13$12$15$14}')

case $dev in
	0x108b8086)
		echo "$1: is a \"82573V Gigabit Ethernet Controller\""
		;;
	0x108c8086)
		echo "$1: is a \"82573E Gigabit Ethernet Controller\""
		;;
	0x109a8086)
		echo "$1: is a \"82573L Gigabit Ethernet Controller\""
		;;
	*)
		echo "No appropriate hardware found for this fixup"
		exit 1
		;;
esac

echo "This fixup is applicable to your hardware"

var=$(ethtool -e $1 | grep 0x0010 | awk '{print $16}')
new=$(echo ${var:0:1}`echo ${var:1} | tr '02468ace' '13579bdf'`)

if [ ${var:0:1}${var:1} == $new ]; then
	echo "Your eeprom is up to date, no changes were made"
	exit 2
fi

echo "executing command: ethtool -E $1 magic $dev offset 0x1e value 0x$new"
ethtool -E $1 magic $dev offset 0x1e value 0x$new

echo "Change made. You *MUST* reboot your machine before changes take effect!"

# end
