#!/bin/bash
stty -echo
trap "stty echo" INT
# DEPENDENCIES:
#	Linux:
#		bash
#		coreutils
#		grep
#		make
#		netcat
#		openssh-client
#		sshpass
#
#	iOS:
#		coreutils-bin
#		dpkg
#		libactivator
#		uikittools

if [[ ${#} != 1 ]]; then
	echo -e "[\e[91;1m-\e[0m] USAGE:\t\e[94;1m${0}\e[0m \e[93;1m<IP address>\e[0m"
	stty echo
	exit 1
fi

echo -en "[\e[37;1m?\e[0m] Checking if host: '\e[93;1m${1}\e[0m' is online\r["
netcat -z ${1} 22 &> /dev/null
if [[ ${?} != 0 ]]; then
	echo -e "\e[91;1m-\e[0m"
	stty echo
	exit 2
else
	echo -e "\e[92;1m+\e[0m"
fi

if [[ ! -f ~/.ssh/root@${1}.pub ]]; then
	echo -en "[\e[37;1m?\e[0m] Generating SSH public key in '\e[93;1m~/.ssh/root@${1}\e[0m'\r["
	ssh-keygen -t rsa -N "" -f ~/.ssh/root@${1} &> /dev/null
	if [[ ${?} != 0 ]]; then
		echo -e "\e[91;1m-\e[0m"
		stty echo
		exit 3
	else
		echo -e "\e[92;1m+\e[0m"
		stty echo
		echo -en "[\e[92;1m~\e[0m] SSH password (alpine)"
		stty -echo
		read -s SSHPass
		echo
		if [[ ${SSHPass} == "" ]]; then
			SSHPass="alpine"
		fi

		echo -en "\e[37;1m\?\e[0m] Sending '\e[93;1m~/.ssh/root@${1}\e[0m' to \e[91;1mroot@${1}\e[0m\r["
		sshpass -p "${SSHPass}" ssh-copy-id -o "StrictHostKeyChecking no" -i ~/.ssh/root@${1}.pub root@${1} &> /dev/null
		if [[ ${?} != 0 ]]; then
			echo -e "\e[91;1m-\e[0m"
			stty echo
			exit 4
		else
			echo -e "\e[92;1m+\e[0m"
		fi
	fi
else
	echo -e "[\e[94;1m+\e[0m] SSH public key found for '\e[93;1mroot@${1}\e[0m'"
fi

echo "{"
echo -e "\t\e[0m'\e[94;1mPackage\e[0m':\t'\e[93;1m$(grep Package control | cut -d ':' -f 2 | tail -c+2)\e[0m',"
echo -e "\t\e[0m'\e[94;1mName\e[0m':\t\t'\e[93;1m$(grep Name control | cut -d ':' -f 2 | tail -c+2)\e[0m',"
echo -e "\t\e[0m'\e[94;1mDependencies\e[0m':\t'\e[93;1m$(grep Depends control | cut -d ':' -f 2 | tail -c+2)\e[0m',"
echo -e "\t\e[0m'\e[94;1mVersion\e[0m':\t'\e[93;1m$(grep Version control | cut -d ':' -f 2 | tail -c+2)\e[0m',"
echo -e "\t\e[0m'\e[94;1mArch\e[0m':\t\t'\e[93;1m$(grep Architecture control | cut -d ':' -f 2 | tail -c+2)\e[0m',"
echo -e "\t\e[0m'\e[94;1mDescription\e[0m':\t'\e[93;1m$(grep Description control | cut -d ':' -f 2 | tail -c+2)\e[0m',"
echo -e "\t\e[0m'\e[94;1mMaintainer\e[0m':\t'\e[93;1m$(grep Maintainer control | cut -d ':' -f 2 | tail -c+2)\e[0m',"
echo -e "\t\e[0m'\e[94;1mAuthor\e[0m':\t'\e[93;1m$(grep Author control | cut -d ':' -f 2 | tail -c+2)\e[0m',"
echo -e "\t\e[0m'\e[94;1mSection\e[0m':\t'\e[93;1m$(grep Section control | cut -d ':' -f 2 | tail -c+2)\e[0m'"
echo "}"
echo

echo -en "[\e[37;1m?\e[0m] Removing old packages in \e[93;1m'$(pwd)/packages/\e[0m'\r["
rm -dfr packages/*
if [[ ${?} != 0 ]]; then
	echo -e "\e[91;1m-\e[0m"
	stty echo
	exit 5
else
	echo -e "\e[92;1m+\e[0m"
fi

echo -en "[\e[37;1m?\e[0m] Compiling '\e[93;1m$(grep Name control | cut -d ':' -f 2 | tail -c+2) \e[0m(\e[91;1m$(grep Package control | cut -d ':' -f 2 | tail -c+2)\e[0m)\e[0m'\r["
make package > /dev/null
if [[ ${?} != 0 ]]; then
	echo -e "\e[91;1m-\e[0m"
	stty echo
	exit 6
else
	echo -e "\e[92;1m+\e[0m"
fi

echo -en "[\e[37;1m?\e[0m] Removing old deb files from device: '\e[93;1mroot@${1}\e[0m'\r["
ssh root@${1} "rm /private/var/mobile/$(grep Package control | cut -d ':' -f 2 | tail -c+2)*.deb" &> /dev/null
if [[ ${?} > 1 ]]; then
	echo -e "\e[91;1m-\e[0m"
	stty echo
	exit 7
else
	echo -e "\e[92;1m+\e[0m"
fi

echo -en "[\e[37;1m?\e[0m] Sending deb file to device: '\e[93;1mroot@${1}\e[0m'\r["
scp packages/*.deb root@${1}:/private/var/mobile/ &> /dev/null
if [[ ${?} != 0 ]]; then
	echo -e "\e[91;1m-\e[0m"
	stty echo
	exit 8
else
	echo -e "\e[92;1m+\e[0m"
fi

echo -en "[\e[37;1m?\e[0m] Installing deb file on device: '\e[93;1mroot@${1}\e[0m'\r["
ssh root@${1} "dpkg -i /private/var/mobile/*.deb" &> /dev/null
if [[ ${?} != 0 ]]; then
	echo -e "\e[91;1m-\e[0m"
	stty echo
	exit 9
else
	echo -e "\e[92;1m+\e[0m"
fi

echo -en "[\e[37;1m?\e[0m] Executing '\e[93;1muicache\e[0m' on '\e[93;1mmobile@${1}\e[0m'\r["
ssh root@${1} "su mobile -c 'uicache'" &> /dev/null
if [[ ${?} != 0 ]]; then
	echo -e "\e[91;1m-\e[0m"
	stty echo
	exit 10
else
	echo -e "\e[92;1m+\e[0m"
fi

sleep 1

echo -en "[\e[37;1m?\e[0m] Opening '\e[93;1m$(grep Package control | cut -d ':' -f 2 | tail -c+2)\e[0m'\r["
ssh root@${1} "su mobile -c 'activator send $(grep Package control | cut -d ':' -f 2 | tail -c+2)'" &> /dev/null
if [[ ${?} != 0 ]]; then
	echo -e "\e[91;1m-\e[0m"
	stty echo
	exit 11
else
	echo -e "\e[92;1m+\e[0m"
fi

stty echo
exit 0
