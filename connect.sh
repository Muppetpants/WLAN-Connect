#!/bin/bash
#Usage: To build a wpa_supplicant.conf file, run sudo bash connect.sh.
#Usage: To use an existing wpa_supplicant.conf, run sudo bash connect.sh <ssid.conf>


if [ "${EUID}" -ne 0 ]; then
        echo -e "\n This script requires root privileges (e.g. sudo bash <connect.sh>)"
        echo
	exit 1
fi



if [ -z "$1" ]; then
	read -p "Config filename: " newConf
	read -p "SSID name: " newSSID
	while true; do
		echo
		read -s -p "Passprhase: " newPass1
		echo
		read -s -p "Confirm Passphrase:" newPass2
		echo
		[ "$newPass1" = "$newPass2" ] && break
		echo "Passphrase does not match, try again"
	done
	/usr/bin/wpa_passphrase "$newSSID" "$newPass1" > $newConf.conf
	echo
echo "$newConf.conf was created."
	echo
	echo "You may now run sudo bash connect.sh $newConf.conf to connect to WLAN."
	echo

else
	sudo killall -9 wpa_supplicant 2>/dev/null
	sudo systemctl stop NetworkManger 2>/dev/null
	sudo wpa_supplicant -i wlan0 -c $1 -B
	sleep 2
	sudo dhclient wlan0
	sleep 1
	echo
	iwconfig wlan0 | awk '/ ESSID:/ { print $4}'
	ip a show dev wlan0 | awk -F '[\/ ]+' '/inet / {print $3}'
fi
