#!/bin/bash
#
#======================================================================================
# NAME: Linux_Solaris_logcollector.sh
# PURPOSE: Script to gather useful information/status of the system before implementing 
#          major changes on the servers/environment.
# AUTHOR: arun.kp@hpe.com
# DATE WRITTEN: 27 March 2015
# MODIFICATION HISTORY: 27 March  2015 - Initial release
#                       03 August 2015 - Re-write script into simple format
#                       05 August 2015 - Modified script to support Solaris Zones
#                       09 June   2017 - Re-write script to display command used to collect data
#                       22 March  2018 - Script now supports RHEL 7.x as well
#======================================================================================
#
YELLOW='\033[1;33m'
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
RESET='\033[0m'
#Logs are saved to /var/tmp/server_info
if [ ! -d "/var/tmp/server_info" ];then
   mkdir /var/tmp/server_info
fi
#Backup old server_info.txt if exists
if [ -f "/var/tmp/server_info/server_info.txt" ];then
   cp -p /var/tmp/server_info/server_info.txt /var/tmp/server_info/server_info-`date +%Y%m%d_%H_%M`.txt
   cat /dev/null > /var/tmp/server_info/server_info.txt
fi
HOST=$(uname -n)
printf "$CYAN"
printf "\nPlease wait while script gathering information from $HOST.$YELLOW If the script taking more than$RED 5 minutes$YELLOW to complete, please break the script using 'Ctrl-C' \n "
printf "$RESET"
LOG="/var/tmp/server_info/server_info.txt"
#Find OS Distribution
SYSTYPE=`uname`
case $SYSTYPE in
Linux)
	VERSION=`uname -r |sed -r -n 's/^.*el([[:digit:]]).*$/\1/p'`
	case $VERSION in 
	[5-6])
	printf "$CYAN"
	printf "\nCollecting basic system information......  \n"
	printf "$RESET"
	printf "\nSystem Information\n==================\n" >>$LOG
	printf "\n# uname -a \n$(uname -a)\n" >>$LOG
	printf "\n# date \n$(date)\n" >>$LOG
	printf "\n# uptime \n$(uptime)\n" >>$LOG
	if [ -f "/etc/redhat-release" ];then
	   printf "\n# cat /etc/redhat-release \n$(cat /etc/redhat-release)\n" >>$LOG
	elif [ -f "/etc/SuSE-release" ];then
	   printf "\n# cat /etc/SuSE-release \n$(cat /etc/SuSE-release)\n" >>$LOG
	fi
	printf "\n# cat /etc/hosts \n$(cat /etc/hosts 2>/dev/null)\n" >>$LOG
	printf "$CYAN"
	printf "\nCollecting information about Storage and Filesystems......  \n"
	printf "$RESET"
	printf "\nStorage/Filesystems information\n===============================\n" >>$LOG
	printf "\n# df -h \n$(df -h|sed 's/%/%%/g'  2>/dev/null)\n" >>$LOG
	printf "\n# mount \n$(mount  2>/dev/null)\n" >>$LOG  
	printf "\n# cat /etc/mtab \n$(cat /etc/mtab)\n" >>$LOG 
	printf "\n# cat /etc/fstab \n$(cat /etc/fstab)\n" >>$LOG 
	printf "\n# findmnt \n$(findmnt 2>/dev/null)\n" >>$LOG 
	printf "\n# lsblk \n$(lsblk 2>/dev/null)\n" >>$LOG 
	printf "\n# fdisk -l \n$(fdisk -l 2>/dev/null)\n" >>$LOG
	printf "\n# pvs \n$(pvs 2>/dev/null)\n" >>$LOG
	printf "\n# pvdisplay \n$(pvdisplay 2>/dev/null)\n" >>$LOG
	printf "\n# vgs \n$(vgs 2>/dev/null)\n" >>$LOG
	printf "\n# vgdisplay \n$(vgdisplay 2>/dev/null)\n" >>$LOG
	printf "\n# lvs \n$(lvs 2>/dev/null |sed 's/%/%%/g')\n" >>$LOG 
	printf "\n# lvdisplay \n$(lvdisplay |sed 's/%/%%/g' 2>/dev/null)\n" >>$LOG
	if ! lspci |egrep 'VMware|Microsoft' &>/dev/null ; then
	   printf "\n# multipath -ll \n$(multipath -ll  2>/dev/null)\n" >>$LOG
	fi
	printf "\n# dmsetup table \n$(dmsetup table 2>/dev/null)\n" >>$LOG
	printf "\n# dmsetup info -c \n$(dmsetup info -c 2>/dev/null)\n" >>$LOG 
	printf "\n# iostat -tkx 1 5 \n$(iostat -tkx 1 5|sed 's/%/%%/g'  2>/dev/null)\n" >>$LOG
	printf "$CYAN"
	printf "\nCollecting information about Processes/Application...... \n"
	printf "$RESET"
	printf "\nProcesses/application information\n=================================\n" >>$LOG
	printf "\n# chkconfig --list \n$(chkconfig --list  2>/dev/null)\n" >>$LOG  
	printf "\n# service --status-all \n$(service --status-all 2>/dev/null)\n" >>$LOG 
	printf "\n# top -d 5 -n 1 -b \n$(top -d 5 -n 1 -b | head -30  2>/dev/null|sed 's/%/%%/g' 2>/dev/null)\n" >>$LOG 
	printf "\n# top -a -d 5 -n 1 -b \n$(top -a -d 5 -n 1 -b  2>/dev/null| head -30 |sed 's/%/%%/g')\n" >>$LOG
	printf "\n# ps aux \n$(ps aux |sed 's/%/%%/g'  2>/dev/null)\n" >>$LOG 
	printf "\n# ps -elfT \n$(ps -elfT|sed 's/%/%%/g'  2>/dev/null)\n" >>$LOG  
	if [ -f "/etc/redhat-release" ];then
	   printf "\n# yum repolist all \n$(yum repolist all 2>/dev/null)\n" >>$LOG
	elif [ -f "/etc/SuSE-release" ];then
	   printf "\n# zypper repos \n$(zypper repos 2>/dev/null)\n" >>$LOG
	fi
	printf "\n# rpm -qa --last \n$(rpm -qa --last  2>/dev/null)\n" >>$LOG 
	printf "$CYAN"
	printf "\nCollecting information about Memory/CPU usage......  \n"
	printf "$RESET"
	printf "\nMemory/CPU usage information\n===========================\n" >>$LOG
	printf "\n# free -m \n$(free -m)\n" >>$LOG 
	printf "\n# vmstat 1 5 \n$(vmstat 1 5)\n" >>$LOG 
	printf "\n# sar -r 1 5 \n$(sar -r 1 5|sed 's/%/%%/g')\n" >>$LOG
	printf "\n# cat /proc/meminfo \n$(cat /proc/meminfo)\n" >>$LOG
	printf "\n# grep -ir 'mem\|slab\|sun\|sre\|cache\|buffer\|swap' /proc/meminfo  \n$(grep -ir 'mem\|slab\|sun\|sre\|cache\|buffer\|swap' /proc/meminfo)\n" >>$LOG
	printf "\n# slabtop -o \n$(slabtop -o |head -50|sed 's/%/%%/g')\n" >>$LOG
	printf "\n# cat /proc/slabinfo \n$(cat /proc/slabinfo | awk '{printf "  %6i MB %s \n",$6*$15/256,$1}' | sort -nrk1 | head|sed 's/%/%%/g')\n" >>$LOG
	printf "\n# sar -u 1 5 \n$(sar -u 1 5|sed 's/%/%%/g')\n" >>$LOG
	printf "\n# lscpu \n$(lscpu 2>/dev/null)\n" >>$LOG
	printf "\n# cat /proc/cpuinfo \n$(cat /proc/cpuinfo)\n" >>$LOG
	printf "$CYAN" 
	printf "\nCollecting information about Kernel parameters and boot configuration...... \n" 
	printf "$RESET"
	printf "\nKernel/boot information\n=======================\n" >>$LOG
	if [ -f "/etc/redhat-release" ];then
	   printf "\n# cat /boot/grub/grub.conf \n$(cat /boot/grub/grub.conf)\n" >>$LOG
	   printf "\n# cat /boot/grub/device.map \n$(cat /boot/grub/device.map)\n" >>$LOG
	   printf "\n# cat /proc/cmdline \n$(cat /proc/cmdline)\n" >>$LOG
	elif [ -f "/etc/SuSE-release" ];then
	   printf "\n# cat /boot/grub/menu.lst \n$(cat /boot/grub/menu.lst)\n" >>$LOG
	   printf "\n# cat /boot/grub/device.map \n$(cat /boot/grub/device.map)\n" >>$LOG
	   printf "\n# cat /proc/cmdline \n$(cat /proc/cmdline)\n" >>$LOG
	fi
	printf "\n# sysctl -a \n$(sysctl -a|sed 's/%/%%/g')\n" >>$LOG 
	printf "\n# ulimit -a \n$(ulimit -a)\n" >>$LOG 
	printf "\n# ipcs -a \n$(ipcs -a)\n" >>$LOG 
	printf "\n# lsmod \n$(lsmod)\n" >>$LOG
	printf "$CYAN" 
	printf "\nCollecting information about Network related configuration......  \n"
	printf "$RESET"
	printf "\nNetwork/Routing Information\n=======================\n" >>$LOG
	printf "\n# cat /etc/resolv.conf \n$(cat /etc/resolv.conf 2>/dev/null)\n" >>$LOG
	printf "\n# cat /etc/nsswitch.conf \n$(cat /etc/nsswitch.conf 2>/dev/null)\n" >>$LOG
	printf "\n# ifconfig -a \n$(ifconfig -a 2>/dev/null)\n" >>$LOG
	printf "\n# ip add show \n$(ip add show 2>/dev/null)\n" >>$LOG
	printf "\n# netstat -rn \n$(netstat -rn 2>/dev/null)\n" >>$LOG
	printf "\n# ip route show \n$(ip route show 2>/dev/null)\n" >>$LOG
	if [ -f /proc/net/bonding ];then
	   for i in $(ls /proc/net/bonding);do printf "\n# cat /proc/net/bonding/$i \n" ;cat /proc/net/bonding/$i ;done >>$LOG
	fi 
	for i in $(ifconfig | grep "^[a-z]" | cut -f 1 -d " "|grep -v lo) ; do printf "\n# ethtool $i \n"; ethtool $i;done >>$LOG
	for i in $(ifconfig | grep "^[a-z]" | cut -f 1 -d " "|grep -v lo) ; do printf "\n# ethtool -i $i \n"; ethtool -i $i;done >>$LOG
	for i in $(ls /etc/sysconfig/network-scripts/{ifcfg,route}-* 2>/dev/null) ; do printf "\n# cat $i \n"; cat $i 2>/dev/null;done >>$LOG
	printf "\n# netstat -in \n$(netstat -in 2>/dev/null)\n" >>$LOG 
	printf "\n# netstat -tunlp \n$(netstat -tunlp 2>/dev/null)\n" >>$LOG
	printf "\n# iptables -L -n \n$(iptables -L -n 2>/dev/null)\n" >>$LOG 
	if ! lspci |egrep 'VMware|Microsoft' &>/dev/null ; then
		printf "$CYAN"
		printf "\nCollecting information about server Hardware......\n"
		printf "$RESET"
		printf "\nHardware/Other Information\n==========================\n" >>$LOG
		printf "\n# dmidecode \n$(/usr/sbin/dmidecode -t 0,1,204| grep -e 'Version' -e 'Release Date' -e 'Manufacturer' -e 'Product Name' -e 'Serial Number' -e 'Enclosure Name' -e 'Enclosure Model' -e 'Enclosure Serial' -e 'Server Bay'|cut -f 2 |grep -v Not)\n" >>$LOG 
		printf "\n# lspci  \n$(lspci)\n" >>$LOG 
		printf "\n# dmidecode --type 0,1,12,15,23,32,5,6,16,17 \n$(dmidecode --type 0,1,12,15,23,32,5,6,16,17 2>/dev/null)\n" >>$LOG 
		printf "\n# systool -c fc_host -v \n$(systool -c fc_host -v 2>/dev/null)\n" >>$LOG
	fi
	if [ -f /opt/hp/hp_fibreutils/adapter_info ];then 
	   printf "\n# /opt/hp/hp_fibreutils/adapter_info -v \n$(/opt/hp/hp_fibreutils/adapter_info -v)\n" >>$LOG 
	fi
	;;
	7)
	printf "$CYAN"
	printf "\nCollecting basic system information......  \n"
	printf "$RESET"
	printf "\nSystem Information\n==================\n" >>$LOG
	printf "\n# uname -a \n$(uname -a)\n" >>$LOG
	printf "\n# date \n$(date)\n" >>$LOG
	printf "\n# uptime \n$(uptime)\n" >>$LOG
	if [ -f "/etc/redhat-release" ];then
	   printf "\n# cat /etc/redhat-release \n$(cat /etc/redhat-release)\n" >>$LOG
	elif [ -f "/etc/SuSE-release" ];then
	   printf "\n# cat /etc/SuSE-release \n$(cat /etc/SuSE-release)\n" >>$LOG
	fi
	printf "\n# cat /etc/hosts \n$(cat /etc/hosts 2>/dev/null)\n" >>$LOG
	printf "$CYAN"
	printf "\nCollecting information about Storage and Filesystems......  \n"
	printf "$RESET"
	printf "\nStorage/Filesystems information\n===============================\n" >>$LOG
	printf "\n# df -h \n$(df -h|sed 's/%/%%/g'  2>/dev/null)\n" >>$LOG
	printf "\n# mount \n$(mount  2>/dev/null)\n" >>$LOG  
	printf "\n# cat /etc/mtab \n$(cat /etc/mtab)\n" >>$LOG 
	printf "\n# cat /etc/fstab \n$(cat /etc/fstab)\n" >>$LOG 
	printf "\n# findmnt \n$(findmnt 2>/dev/null)\n" >>$LOG 
	printf "\n# lsblk \n$(lsblk 2>/dev/null)\n" >>$LOG 
	printf "\n# fdisk -l \n$(fdisk -l 2>/dev/null)\n" >>$LOG
	printf "\n# pvs \n$(pvs 2>/dev/null)\n" >>$LOG
	printf "\n# pvdisplay \n$(pvdisplay 2>/dev/null)\n" >>$LOG
	printf "\n# vgs \n$(vgs 2>/dev/null)\n" >>$LOG
	printf "\n# vgdisplay \n$(vgdisplay 2>/dev/null)\n" >>$LOG
	printf "\n# lvs \n$(lvs 2>/dev/null |sed 's/%/%%/g')\n" >>$LOG 
	printf "\n# lvdisplay \n$(lvdisplay |sed 's/%/%%/g' 2>/dev/null)\n" >>$LOG
	if ! lspci |egrep 'VMware|Microsoft' &>/dev/null ; then
	   printf "\n# multipath -ll \n$(multipath -ll  2>/dev/null)\n" >>$LOG
	fi
	printf "\n# dmsetup table \n$(dmsetup table 2>/dev/null)\n" >>$LOG
	printf "\n# dmsetup info -c \n$(dmsetup info -c 2>/dev/null)\n" >>$LOG 
	printf "\n# iostat -tkx 1 5 \n$(iostat -tkx 1 5|sed 's/%/%%/g'  2>/dev/null)\n" >>$LOG
	printf "$CYAN"
	printf "\nCollecting information about Processes/Application...... \n"
	printf "$RESET"
	printf "\nProcesses/application information\n=================================\n" >>$LOG
	printf "\n# systemctl list-unit-files  \n$(systemctl list-unit-files  2>/dev/null)\n" >>$LOG  
	printf "\n# systemctl -at service \n$(systemctl -at service 2>/dev/null)\n" >>$LOG 
	printf "\n# top -d 5 -n 1 -b \n$(top -d 5 -n 1 -b | head -30  2>/dev/null|sed 's/%/%%/g' 2>/dev/null)\n" >>$LOG 
	printf "\n# top -o MEM -d 5 -n 1 -b \n$(top -o %MEM -d 5 -n 1 -b  2>/dev/null| head -30 |sed 's/%/%%/g')\n" >>$LOG
	printf "\n# ps aux \n$(ps aux |sed 's/%/%%/g'  2>/dev/null)\n" >>$LOG 
	printf "\n# ps -elfT \n$(ps -elfT|sed 's/%/%%/g'  2>/dev/null)\n" >>$LOG  
	if [ -f "/etc/redhat-release" ];then
	   printf "\n# yum repolist all \n$(yum repolist all 2>/dev/null)\n" >>$LOG
	elif [ -f "/etc/SuSE-release" ];then
	   printf "\n# zypper repos \n$(zypper repos 2>/dev/null)\n" >>$LOG
	fi
	printf "\n# rpm -qa --last \n$(rpm -qa --last  2>/dev/null)\n" >>$LOG 
	printf "$CYAN"
	printf "\nCollecting information about Memory/CPU usage......  \n"
	printf "$RESET"
	printf "\nMemory/CPU usage information\n===========================\n" >>$LOG
	printf "\n# free -m \n$(free -m)\n" >>$LOG 
	printf "\n# vmstat 1 5 \n$(vmstat 1 5)\n" >>$LOG 
	printf "\n# sar -r 1 5 \n$(sar -r 1 5|sed 's/%/%%/g')\n" >>$LOG
	printf "\n# cat /proc/meminfo \n$(cat /proc/meminfo)\n" >>$LOG
	printf "\n# grep -ir 'mem\|slab\|sun\|sre\|cache\|buffer\|swap' /proc/meminfo  \n$(grep -ir 'mem\|slab\|sun\|sre\|cache\|buffer\|swap' /proc/meminfo)\n" >>$LOG
	printf "\n# slabtop -o \n$(slabtop -o |head -50|sed 's/%/%%/g')\n" >>$LOG
	printf "\n# cat /proc/slabinfo \n$(cat /proc/slabinfo | awk '{printf "  %6i MB %s \n",$6*$15/256,$1}' | sort -nrk1 | head|sed 's/%/%%/g')\n" >>$LOG
	printf "\n# sar -u 1 5 \n$(sar -u 1 5|sed 's/%/%%/g')\n" >>$LOG
	printf "\n# lscpu \n$(lscpu 2>/dev/null)\n" >>$LOG
	printf "\n# cat /proc/cpuinfo \n$(cat /proc/cpuinfo)\n" >>$LOG
	printf "$CYAN" 
	printf "\nCollecting information about Kernel parameters and boot configuration...... \n" 
	printf "$RESET"
	printf "\nKernel/boot information\n=======================\n" >>$LOG
	if [ -f "/etc/redhat-release" ];then
	   printf "\n# cat /boot/grub2/grub.cfg \n$(cat /boot/grub2/grub.cfg)\n" >>$LOG
	   printf "\n# cat /boot/grub2/device.map \n$(cat /boot/grub2/device.map)\n" >>$LOG
	   printf "\n# cat /proc/cmdline \n$(cat /proc/cmdline)\n" >>$LOG
	elif [ -f "/etc/SuSE-release" ];then
	   printf "\n# cat /boot/grub2/grub.cfg \n$(cat /boot/grub2/grub.cfg)\n" >>$LOG
	   printf "\n# cat /boot/grub2/device.map \n$(cat /boot/grub2/device.map)\n" >>$LOG
	   printf "\n# cat /proc/cmdline \n$(cat /proc/cmdline)\n" >>$LOG
	fi
	printf "\n# sysctl -a \n$(sysctl -a|sed 's/%/%%/g')\n" >>$LOG 
	printf "\n# ulimit -a \n$(ulimit -a)\n" >>$LOG 
	printf "\n# ipcs -a \n$(ipcs -a)\n" >>$LOG 
	printf "\n# lsmod \n$(lsmod)\n" >>$LOG
	printf "$CYAN" 
	printf "\nCollecting information about Network related configuration......  \n"
	printf "$RESET"
	printf "\nNetwork/Routing Information\n=======================\n" >>$LOG
	printf "\n# cat /etc/resolv.conf \n$(cat /etc/resolv.conf 2>/dev/null)\n" >>$LOG
	printf "\n# cat /etc/nsswitch.conf \n$(cat /etc/nsswitch.conf 2>/dev/null)\n" >>$LOG
	printf "\n# ifconfig -a \n$(ifconfig -a 2>/dev/null)\n" >>$LOG
	printf "\n# ip add show \n$(ip add show 2>/dev/null)\n" >>$LOG
	printf "\n# netstat -rn \n$(netstat -rn 2>/dev/null)\n" >>$LOG
	printf "\n# ip route show \n$(ip route show 2>/dev/null)\n" >>$LOG
	if [ -f /proc/net/bonding ];then
	   for i in $(ls /proc/net/bonding);do printf "\n# cat /proc/net/bonding/$i \n" ;cat /proc/net/bonding/$i ;done >>$LOG
	fi 
	for i in $(ifconfig | grep "^[a-z]" | cut -f 1 -d " "|grep -v lo) ; do printf "\n# ethtool $i \n"; ethtool $i;done >>$LOG
	for i in $(ifconfig | grep "^[a-z]" | cut -f 1 -d " "|grep -v lo) ; do printf "\n# ethtool -i $i \n"; ethtool -i $i;done >>$LOG
	for i in $(ls /etc/sysconfig/network-scripts/{ifcfg,route}-* 2>/dev/null) ; do printf "\n# cat $i \n"; cat $i 2>/dev/null;done >>$LOG
	printf "\n# netstat -in \n$(netstat -in 2>/dev/null)\n" >>$LOG 
	printf "\n# netstat -tunlp \n$(netstat -tunlp 2>/dev/null)\n" >>$LOG
	printf "\n# iptables -L -n \n$(iptables -L -n 2>/dev/null)\n" >>$LOG 
	printf "\n# firewall-cmd --list-all \n$(firewall-cmd --list-all 2>/dev/null)\n" >>$LOG 
	if ! lspci |egrep 'VMware|Microsoft' &>/dev/null ; then
		printf "$CYAN"
		printf "\nCollecting information about server Hardware......\n"
		printf "$RESET"
		printf "\nHardware/Other Information\n==========================\n" >>$LOG
		printf "\n# dmidecode \n$(/usr/sbin/dmidecode -t 0,1,204| grep -e 'Version' -e 'Release Date' -e 'Manufacturer' -e 'Product Name' -e 'Serial Number' -e 'Enclosure Name' -e 'Enclosure Model' -e 'Enclosure Serial' -e 'Server Bay'|cut -f 2 |grep -v Not)\n" >>$LOG 
		printf "\n# lspci  \n$(lspci)\n" >>$LOG 
		printf "\n# dmidecode --type 0,1,12,15,23,32,5,6,16,17 \n$(dmidecode --type 0,1,12,15,23,32,5,6,16,17 2>/dev/null)\n" >>$LOG 
		printf "\n# systool -c fc_host -v \n$(systool -c fc_host -v 2>/dev/null)\n" >>$LOG
	fi
	if [ -f /opt/hp/hp_fibreutils/adapter_info ];then 
	   printf "\n# /opt/hp/hp_fibreutils/adapter_info -v \n$(/opt/hp/hp_fibreutils/adapter_info -v)\n" >>$LOG 
	fi
	;;
	*)
	printf "\n Unsupported OS - Supported Operating Systems are : Solaris 9(partially),10 and Red Hat EL 5.x, 6.x , 7.x \n\n" 1>&2
	exit 1
	esac
;;
SunOS)
	printf "$CYAN"
	printf "\nCollecting basic system information......  \n"
	printf "$RESET"
	printf "\nSystem Information\n==================\n" >>$LOG
	printf "\n# uname -a \n$(uname -a)\n" >>$LOG
	printf "\n# date \n$(date)\n" >>$LOG
	printf "\n# uptime \n$(uptime)\n" >>$LOG
	printf "\n# cat /etc/release \n$(cat /etc/release 2>/dev/null)\n" >>$LOG
	printf "\n# cat /etc/hosts \n$(cat /etc/hosts 2>/dev/null)\n" >>$LOG
	printf "\n# cat /etc/nodename \n$(cat /etc/nodename 2>/dev/null)\n" >>$LOG
	if [ $(zonename 2>/dev/null) = "global" 2>/dev/null ];then
	for i in $(ls /etc/hostname.* 2>/dev/null );do printf "\n# cat $i \n" ;cat $i ;done >>$LOG
	printf "\n# zoneadm list \n$(zoneadm list 2>/dev/null)\n" >>$LOG
	printf "\n# zoneadm list -cv \n$(zoneadm list -cv 2>/dev/null)\n" >>$LOG
	for Z in $(zoneadm list | grep -v '^global$' ) ;do printf "\n# zonecfg -z $Z info \n";zonecfg -z $Z info 2>/dev/null;done  >>$LOG
	fi
	printf "$CYAN"
	printf "\nCollecting information about Storage and Filesystems......  \n"
	printf "$RESET"
	printf "\nStorage/Filesystems information\n===============================\n" >>$LOG
	printf "\n# df -h \n$(df -h|sed 's/%/%%/g' 2>/dev/null)\n" >>$LOG
	printf "\n# mount \n$(mount)\n" >>$LOG  
	printf "\n# cat /etc/mnttab \n$(cat /etc/mnttab 2>/dev/null)\n" >>$LOG 
	printf "\n# cat /etc/vfstab \n$(cat /etc/vfstab 2>/dev/null)\n" >>$LOG 
	if [ $(zonename 2>/dev/null) = "global" 2>/dev/null  ];then
	printf "\n# format \n$(echo | format)\n" >>$LOG
	printf "\n# iostat -Een \n$(iostat -Een |sed 's/%/%%/g' 2>/dev/null)\n" >>$LOG
	printf "\n# metastat \n$(metastat 2>/dev/null)\n" >>$LOG
	printf "\n# metastat -p \n$(metastat -p 2>/dev/null)\n" >>$LOG
	printf "\n# metastat -c \n$(metastat -c 2>/dev/null)\n" >>$LOG
	printf "\n# metadb -i \n$(metadb -i 2>/dev/null )\n" >>$LOG
	for i in $(metadb | grep dsk | sed -e 's~.*/dsk/~~g' | sed -e 's/s.$//' |sort -u);do printf "\n# prtvtoc /dev/rdsk/${i}s2  \n";prtvtoc /dev/rdsk/${i}s2 2>/dev/null;done  >>$LOG
	printf "\n# vxdg list \n$(vxdg list 2>/dev/null)\n" >>$LOG
	printf "\n# vxdisk list \n$(vxdisk list 2>/dev/null)\n" >>$LOG
	printf "\n# vxprint -ht \n$(vxprint -ht 2>/dev/null)\n" >>$LOG
	fi
	printf "\n# zpool list  \n$(zpool list 2>/dev/null |sed 's/%/%%/g' )\n" >>$LOG
	printf "\n# zfs list \n$(zfs list 2>/dev/null)\n" >>$LOG
	printf "\n# zpool status -v \n$(zpool status -v 2>/dev/null)\n" >>$LOG
	printf "\n# iostat -xnmpz \n$(iostat -xnmpz 1 5 |tail -200|sed 's/%/%%/g' 2>/dev/null)\n" >>$LOG
	printf "$CYAN"
	printf "\nCollecting information about Processes/Application...... \n"
	printf "$RESET"
	printf "\nProcesses/application information\n=================================\n" >>$LOG
	printf "\n# svcs -a \n$(svcs -a 2>/dev/null)\n" >>$LOG
	printf "\n# prstat -s cpu  -can 50 \n$(prstat -s cpu  -can 50 1 1|sed 's/%/%%/g' 2>/dev/null)\n" >>$LOG
	printf "\n# prstat -s rss  -can 50 \n$(prstat -s rss  -can 50 1 1|sed 's/%/%%/g' 2>/dev/null)\n" >>$LOG
	printf "\n# ps -ef \n$(ps -ef 2>/dev/null)\n" >>$LOG
	printf "\n# ps -eZfly \n$(ps -eZfly 2>/dev/null)\n" >>$LOG
	printf "\n# pkginfo \n$(pkginfo 2>/dev/null)\n" >>$LOG
	printf "$CYAN"
	printf "\nCollecting information about Memory/CPU usage......  \n"
	printf "$RESET"
	printf "\nMemory/CPU usage information\n===========================\n" >>$LOG
	printf "\n# swap -l \n$(swap -l 2>/dev/null)\n" >>$LOG
	printf "\n# swap -s \n$(swap -s 2>/dev/null)\n" >>$LOG
	printf "\n# vmstat 1 5 \n$(vmstat 1 5 2>/dev/null)\n" >>$LOG
	printf "\n# sar -u 1 5 \n$(sar -u 1 5|sed 's/%/%%/g' 2>/dev/null)\n" >>$LOG
	printf "\n# uname -X \n$(uname -X 2>/dev/null)\n" >>$LOG
	printf "\n# psrinfo -pv \n$(psrinfo -pv 2>/dev/null)\n" >>$LOG
	printf "\n# uptime \n$(uptime 2>/dev/null)\n" >>$LOG
	printf "$CYAN"
	printf "\nCollecting information about Kernel parameters and boot disks...... \n" 
	printf "$RESET"
	printf "\nKernel/boot information\n=======================\n" >>$LOG
	printf "\n# cat /etc/system \n$(cat /etc/system 2>/dev/null)\n" >>$LOG
	printf "\n# ulimit -a \n$(ulimit -a 2>/dev/null)\n" >>$LOG 
	printf "\n# ipcs -a \n$(ipcs -a 2>/dev/null)\n" >>$LOG 
	printf "\n# prtconf -pv |grep disk \n$(prtconf -pv |grep disk 2>/dev/null)\n" >>$LOG
	printf "\n# eeprom \n$(eeprom 2>/dev/null)\n" >>$LOG
	printf "$CYAN"
	printf "\nCollecting information about Network related configuration......  \n"
	printf "$RESET"
	printf "\nNetwork/Routing Information\n=======================\n" >>$LOG
	printf "\n# ifconfig -a \n$(ifconfig -a)\n" >>$LOG
	if [ $(zonename 2>/dev/null) = "global" 2>/dev/null  ];then
	for i in $(ls /etc/hostname.* 2>/dev/null );do printf "\n# cat $i \n" ;cat $i ;done >>$LOG
	printf "\n# cat /etc/defaultrouter \n$(cat /etc/defaultrouter 2>/dev/null)\n" >>$LOG
	printf "\n# dladm show-dev \n$(dladm show-dev 2>/dev/null)\n" >>$LOG 
	printf "\n# dladm show-link \n$(dladm show-link 2>/dev/null)\n" >>$LOG 
	fi
	printf "\n# netstat -rn \n$(netstat -rn)\n" >>$LOG
	printf "\n# netstat -in \n$(netstat -in)\n" >>$LOG
	printf "\n# netstat -an \n$(netstat -an)\n" >>$LOG
	printf "\n# cat /etc/resolv.conf \n$(cat /etc/resolv.conf 2>/dev/null)\n" >>$LOG
	printf "\n# cat /etc/nsswitch.conf \n$(cat /etc/nsswitch.conf 2>/dev/null)\n" >>$LOG
	if [ -f /usr/sbin/ldm ]; then
	printf "$CYAN"
	printf "\nCollecting information about LDOM configuration......\n"
	printf "$RESET"
	printf "\nLDOM configuration Information\n==========================\n" >>$LOG
	printf "\n# ldm list  \n$(ldm list  2>/dev/null)\n" >>$LOG
	printf "\n# ldm ls-spconfig \n$(ldm ls-spconfig 2>/dev/null)\n" >>$LOG
	printf "\n# ldm list -l  \n$(ldm list -l |sed 's/%/%%/g' 2>/dev/null)\n" >>$LOG
	printf "\n# ldm list-bindings  \n$(ldm list-bindings |sed 's/%/%%/g'  2>/dev/null)\n" >>$LOG
	printf "\n# ldm list-devices -a  \n$(ldm list-devices -a  2>/dev/null)\n" >>$LOG
	printf "\n# ldm list-constraints -x  \n$(ldm list-constraints -x  2>/dev/null)\n" >>$LOG
	fi
	if [ $(zonename 2>/dev/null) = "global" 2>/dev/null ];then
	printf "$CYAN"
	printf "\nCollecting information about server Hardware......\n"
	printf "$RESET"
	printf "\nHardware/Other Information\n==========================\n" >>$LOG
	printf "\n# prtdiag -v \n$(prtdiag -v 2>/dev/null)\n" >>$LOG
	printf "\n# luxadm -e port \n$(luxadm -e port 2>/dev/null)\n" >>$LOG
	printf "\n# fcinfo hba-port \n$(fcinfo hba-port 2>/dev/null)\n" >>$LOG
	printf "\n# cfgadm -al \n$(cfgadm -al 2>/dev/null)\n" >>$LOG
	printf "\n# fmadm faulty \n$(fmadm faulty 2>/dev/null)\n" >>$LOG
	printf "\n# fmdump \n$(fmdump 2>/dev/null)\n" >>$LOG
	fi
;;
*)
printf "\n Unsupported OS - Supported Operating Systems are : Solaris 9(partially),10 and Red Hat EL 5.x, 6.x , 7.x \n\n" 1>&2
exit 1
;;
esac
#Informational message
printf "$CYAN"
printf "\nInformation gathered are written to $GREEN /var/tmp/server_info/server_info.txt $RESET\n\n"