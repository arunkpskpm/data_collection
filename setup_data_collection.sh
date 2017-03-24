#!/bin/bash
#
#========================================================================
# NAME: setup_data_collection.sh
# PURPOSE: This script will prepare a "new" script /var/tmp/srvmon/perf_monitor.sh on Linux/Solaris servers. New script will be added to crontab, scheduled to run every minutes.
# Performance logs will be saved under /var/tmp/srvmon. Log rotation will be enabled to rotate log files weekly (will keep 6 older versions of logs)
# AUTHOR: arun.kp@hpe.com
# DATE WRITTEN: 21 July 2016
# MODIFICATION HISTORY: 21 July 2016 - Initial release
# MODIFICATION HISTORY: 20 March 2017 - Added Solaris log rotation 
#========================================================================
#
#Colour code
RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
RESET='\033[0m'
#Check exit code and exit the script if any error. 
check_error () {
if [ $? -ne 0 ]; then
	printf "\n$RED Error. Please re-run the script in debug mode (sh -x setup_data_collection.sh) to identify the problem. \n $RESET"
	exit 1
fi
}
#Checking if someone already placed a script on the server 
if crontab  -l |grep perf_monitor.sh >/dev/null 2>&1; then
	printf "\n\n$RED Script already exists in the root's crontab. Please verify before re-running the setup $RESET \n\n"
	exit 1
fi
#printing some informational notes
printf "\n$CYAN Preparing script $GREEN /var/tmp/srvmon/perf_monitor.sh $CYAN for performance data collection...$RESET"
printf "\n$CYAN Logs will be saved to $GREEN /var/tmp/srvmon $RESET"
#Logs are saved to /var/tmp/srvmon 
if [ ! -d "/var/tmp/srvmon" ]
then
    mkdir /var/tmp/srvmon
	check_error
fi
#Find OS Distribution and setup script based on Operating System running
SYSTYPE=`uname`
case $SYSTYPE in
    Linux)
#Preparing script /var/tmp/srvmon/perf_monitor.sh
cat > /var/tmp/srvmon/perf_monitor.sh << "End-of-message"
#!/bin/bash
#
#========================================================================
# NAME: perf_monitor.sh
# PURPOSE: Script to collect performance data from the server
# AUTHOR: arun.kp@hpe.com
# DATE WRITTEN: 06 August 2015
# MODIFICATION HISTORY: 06 Aug 2015 - Initial release
#                       31 Oct 2016 - Added sar,pidstat commands
#========================================================================
#Defining commands to use
DATE=`date`
TOPCPU=`top -d 5 -n 1 -b | head -30 |sed 's/%/%%/g'`           #top sorted based on CPU usage
TOPMEM=`top -a -d 5 -n 1 -b | head -30 |sed 's/%/%%/g'`        #top sorted based on Memory usage
SWAP=` free | grep -i swap | tr -d [A-z],\:,\+,\=,\-,\/, | awk '{print"Swap free: "($3)/($1)*100"%"}' |sed 's/%/%%/g'`
VMSTAT=`vmstat 1 10`
IOSTAT=`iostat -xdmtc 1 5 |sed 's/%/%%/g' `
SARCPU=`sar -u 1 10 |sed 's/%/%%/g'`                           #increase to 60 seconds if needed 
SARMEM=`sar -r 1 10 |sed 's/%/%%/g'`                           #increase to 60 seconds if needed
PIDSTAT=`pidstat 1 10 |sed 's/%/%%/g'`                         #increase to 60 seconds if needed
#Defining log file path
LOG_TOPCPU="/var/tmp/srvmon/top_cpu.log"
LOG_TOPMEM="/var/tmp/srvmon/top_mem.log"
LOG_SWAP="/var/tmp/srvmon/swap.log"
LOG_VMSTAT="/var/tmp/srvmon/vmstat.log"
LOG_IOSTAT="/var/tmp/srvmon/iostat.log"
LOG_PIDSTAT="/var/tmp/srvmon/pidstat.log"
LOG_SARCPU="/var/tmp/srvmon/sar_cpu.log"
LOG_SARMEM="/var/tmp/srvmon/sar_mem.log"
#Writing logs collected
printf "\n $DATE \n $TOPCPU \n " >>$LOG_TOPCPU
printf "\n $DATE \n $TOPMEM \n " >>$LOG_TOPMEM
printf "\n $DATE \n $SWAP \n " >>$LOG_SWAP
printf "\n $DATE \n $VMSTAT \n " >>$LOG_VMSTAT
printf "\n $DATE \n $IOSTAT \n " >>$LOG_IOSTAT
printf "\n $DATE \n $PIDSTAT \n " >>$LOG_PIDSTAT
printf "\n $DATE \n $SARCPU \n " >>$LOG_SARCPU
printf "\n $DATE \n $SARMEM \n " >>$LOG_SARMEM
End-of-message
#Making script executable
chmod +x /var/tmp/srvmon/perf_monitor.sh
check_error 
#Adding script to crontab
printf "\n$CYAN Adding script to crontab... \n\n $RESET"
echo "#Script placed by UNIX team to collect performance data" >> /var/spool/cron/root
echo "* * * * * /var/tmp/srvmon/perf_monitor.sh  >/dev/null 2>&1 " >> /var/spool/cron/root
check_error
#Setting up log rotation 
cat > /etc/logrotate.d/srvmon  << "End-of-message"
/var/tmp/srvmon/top_cpu.log /var/tmp/srvmon/top_mem.log /var/tmp/srvmon/swap.log /var/tmp/srvmon/vmstat.log /var/tmp/srvmon/iostat.log /var/tmp/srvmon/pidstat.log /var/tmp/srvmon/sar_cpu.log /var/tmp/srvmon/sar_mem.log
{
    compress
    weekly
    rotate 6
    create 600
}
End-of-message
#Restarting syslogd to reflect the changes done on logrotate
#printf "\n$CYAN Restarting rsyslog/syslogd service to refresh the log rotation configuration. $RESET \n\n"  
SYSLOGD=`chkconfig --list |grep -w -e syslog -e rsyslog | awk '{print $1}'`
service $SYSLOGD restart  >/dev/null 2>&1
check_error
	;;
	SunOS) 
cat > /var/tmp/srvmon/perf_monitor.sh  << "End-of-message"
#!/bin/bash
#
#========================================================================
# NAME: perf_monitor.sh
# PURPOSE: Script to collect real-time system performance data from a Solaris server
# AUTHOR: arun.kp@hpe.com
# DATE WRITTEN: 06 August 2015
# MODIFICATION HISTORY: 06 August 2015 - Initial release
#========================================================================
#Defining variables
DATE=`date`
PRSTATCPU=`prstat -s cpu  -can 50 1 1|sed 's/%/%%/g'`		# prstat sorted based on cpu utilization. 
PRSTATMEM=`prstat -s rss  -can 50 1 1|sed 's/%/%%/g'` 		# prstat sorted based on memory utilization.  
SWAP=`swap -s | awk ' { print $9 $11 } ' | awk -Fk '{print $1 * 100 / ( $1 + $2 ) }'`
VMSTAT=`vmstat 1 5`
IOSTAT=`iostat -xnmpz 2 5 |tail -200|sed 's/%/%%/g'`
LOG_PRSTATCPU="/var/tmp/srvmon/prstat_cpu.log"
LOG_PRSTATMEM="/var/tmp/srvmon/prstat_mem.log"
LOG_SWAP="/var/tmp/srvmon/swap.log"
LOG_VMSTAT="/var/tmp/srvmon/vmstat.log"
LOG_IOSTAT="/var/tmp/srvmon/iostat.log"
#Writing logs collected
printf "\n $DATE \n $PRSTATCPU \n " >>$LOG_PRSTATCPU
printf "\n $DATE \n $PRSTATMEM \n " >>$LOG_PRSTATMEM
printf "\n $DATE \n $SWAP \n " >>$LOG_SWAP
printf "\n $DATE \n $VMSTAT \n " >>$LOG_VMSTAT
printf "\n $DATE \n $IOSTAT \n " >>$LOG_IOSTAT
End-of-message
#Making script executable
chmod +x /var/tmp/srvmon/perf_monitor.sh 
check_error
#Adding script to crontab
printf "\n$CYAN Adding script to crontab... \n $RESET"
echo "#Script placed by UNIX team to collect performance data" >> /var/spool/cron/crontabs/root
echo "* * * * * /var/tmp/srvmon/perf_monitor.sh  >/dev/null 2>&1 " >> /var/spool/cron/crontabs/root
check_error
#Restarting crond to reflect the changes done 
svcadm restart cron 
#Running script for one time to get generate the output files
printf "\n$CYAN Please wait while running script for first time... \n $RESET"
/var/tmp/srvmon/perf_monitor.sh 
#Setting up log rotation 
logadm -w /var/tmp/srvmon/prstat_cpu.log -C 6 -p 1w -c -z 0
logadm -w /var/tmp/srvmon/prstat_mem.log -C 6 -p 1w -c -z 0
logadm -w /var/tmp/srvmon/swap.log -C 6 -p 1w -c -z 0
logadm -w /var/tmp/srvmon/vmstat.log -C 6 -p 1w -c -z 0
logadm -w /var/tmp/srvmon/iostat.log -C 6 -p 1w -c -z 0
check_error
	;;
    *)
        printf "\n Unsupported OS - $SYSTYPE \n\n" 1>&2
        exit 1
    ;;
esac
