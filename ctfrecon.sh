#!/bin/bash

# User Input
IP=$1
DIR_NAME=$2
PLATFORM=$3
WORDLIST=$4

# Regex Matching
RE='\.txt$'

# Check if user inputted necessary parameters (IP, Directory name, Platform)
if [ "$1" == "-h" ]
then
	echo "[i] Usage: ./ctfrecon.sh [IP] [Directory Name] [Platform]"	
	echo "[i] ctfrecon is recommended to be run as root!"
elif (( $# != 4 ))
then
	echo "[-] Error: Number of arguments passed: $#"
	echo "[i] Number of parameters required: 4"
	echo "[i] Usage: ./ctfrecon.sh [IP] [Directory Name] [Platform]"

elif ! [[ "$4" =~  $RE ]]
then
	echo "[-] Error: Invalid Wordlist!"
	echo "[i] Exiting..."
	pkill -KILL $(echo $$)

else

	# Create directory inputted by user.
	mkdir $DIR_NAME
	cd $DIR_NAME/
	mkdir $IP/
	cd $IP/
	mkdir loot scans ss exploit
	clear
	echo "[+] Successfully created $DIR_NAME directory!"
	echo "[i] Adding ${DIR_NAME}.${PLATFORM} to /etc/hosts!\n"
	if (($(whoami) == "root"))
	then
		echo "$IP ${DIR_NAME}.${PLATFORM}" >> /etc/hosts >/dev/null
		echo "[+] Successfully added ${DIR_NAME}.${PLATFORM} to /etc/hosts"
	else
		echo "[-] Error: Please run ctfrecon as root!"
		echo "[i] Exiting..."
		pkill -KILL ctfrecon.sh

		# Scanning using nmap
		echo "[+] Now Scanning network using nmap..\n."
		nmap -T4 -A -p- -oN scans/${DIR_NAME}_nmap_scan.txt $IP >/dev/null

		echo "[+] Nmap scan: Finished"
		echo "[+] Log files saved at scans/ directory!\n"
		wait

		# Directory busting using GoBuster
		echo "[i] Initializing GoBuster for directory bruteforcing...\n"
		gobuster dir -u http://${DIR_NAME}.${PLATFORM} -w $WORDLIST -t 64 -o scans/${DIR_NAME}_GoBuster_scan.txt &>/dev/null
		wait
		echo "[+] Log files saved at scans directory!"
		echo "[+] GoBuster Directory Bruteforcing: Finished\n"

		# Cleaning permissions of directories
		cd ../../
		chmod 755 $(pwd)/$DIR_NAME/
		chown -R 1000:1000 $(pwd)/$DIR_NAME/
	fi
fi
