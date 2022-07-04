#!/usr/bin/env bash

if [[ $1 == "-Debug" || $1 == "-debug" || $1 == "-d" || $1 == "-D"  ]]
        then 
	    set -x
	    echo "Debug mode enabled"
fi

HOSTNAME=`scutil --get LocalHostName`
NOW=`date +%Y-%m-%dT%H:%M:%S%z`
ODCFILENAME="$HOSTNAME-IntuneMacODC-$NOW.zip"

if [ "$EUID" -ne 0 ]
    then echo -e "Please run using 'sudo ./IntuneMacODC.sh'"
    exit
fi

echo "Creating odc working directory"
if [ ! -d odc ]
   then mkdir odc
fi
pushd .
cd odc

sw_vers > ./sw_vers.txt
zip -r $ODCFILENAME ./sw_vers.txt

uname -a > ./uname_a.txt
zip -r $ODCFILENAME ./uname_a.txt

echo -e "************************\n" >> ./profiles.txt
echo -e "profiles status\n\n" >> ./profiles.txt
profiles status >> ./profiles.txt

echo -e "************************\n" >> ./profiles.txt
echo -e "profiles list\n\n" >> ./profiles.txt
profiles list >> ./profiles.txt

echo -e "************************\n" >> ./profiles.txt
echo -e "profiles show\n\n" >> ./profiles.txt
profiles show >> ./profiles.txt

echo -e "************************\n" >> ./profiles.txt
echo -e "profiles list -verbose\n\n" >> ./profiles.txt
profiles list -verbose >> ./profiles.txt

echo -e "************************\n" >> ./profiles.txt
echo -e "profiles show -verbose\n\n" >> ./profiles.txt
profiles show -verbose >> ./profiles.txt

zip -r $ODCFILENAME ./profiles.txt

echo "Collecting logs"
# Gather log directories 
zip -r $ODCFILENAME ~/Library/Logs/Company\ Portal/*
zip -r $ODCFILENAME ~/Library/Logs/Microsoft/*
zip -r $ODCFILENAME /var/log/*
zip -r $ODCFILENAME /Library/Logs/Microsoft/*
zip -r $ODCFILENAME /Library/Application\ Support/Microsoft/Intune/SideCar
zip -r $ODCFILENAME /usr/local/jamf/bin/jamfAAD/*
zip -r $ODCFILENAME ~/Library/Logs/DiagnosticReports/* -x "*Siri*"

# pkg utilities
#
#

pkgutil --pkgs > ./pkgutil_pkgs.txt
pkgutil --pkgs | grep - v com.apple.pkg.MAContent10 | while read x; do (pkgutil --pkg-info $x; echo -e ""); done > ./pkgutil_info.txt

zip -r $ODCFILENAME ./pkgutil_pkgs.txt
zip -r $ODCFILENAME ./pkgutil_info.txt

echo "Gathering syslogs.  This may take a minute."

# Syslogs
log show --style syslog --info --debug --predicate 'process CONTAINS[c] "downloadd" ' --last 30d  >> ./syslog_downloadd.log
zip -r $ODCFILENAME ./syslog_downloadd.log

log show --style syslog --info --debug  --predicate 'process BEGINSWITH "Intune" || eventMessage CONTAINS[c] "Intune" || process CONTAINS[c] "appstore" || process CONTAINS[c] "downloadd" || process CONTAINS "mdm" ' --last 30d  >> ./syslog_intune.log
zip -r $ODCFILENAME ./syslog_intune.log

# Push Notifications (APNS)
log show --style syslog --info --debug --predicate 'process CONTAINS[c] "apsd" || eventMessage CONTAINS[c] "apsd"  ' --last 30d >> ./syslog_apns.log
zip -r $ODCFILENAME ./syslog_apns.log

if [ -d /usr/local/jamf/bin/jamfAAD ]; then
	log show -style syslog --info --debug --predicate 'subsystem CONTAINS "jamfAAD"' --last 30d >> ./syslog_jamfAAD.log
else
	echo -e "/usr/local/jamf/bin/jamfAAD not found, skipping JAMF" >> ./syslog_jamfAAD.log
fi
zip -r $ODCFILENAME ./syslog_jamfAAD.log

echo "Gathering system profiler"
#######################################################################################
# System Report - double-click to open utility
#

/usr/sbin/system_profiler -detailLevel full -xml > ./SystemReport.spx 2>/dev/null
zip -r $ODCFILENAME ./SystemReport.spx

echo "Gathering profiles data"
#######################################################################################
# Profiles Data
#
echo -e "profiles status\n**************************\n\n" > ./IntuneProfiles.txt
profiles status >> .//IntuneProfiles.txt

echo -e "profiles list\n**************************\n\n" > ./IntuneProfiles.txt
profiles list >> .//IntuneProfiles.txt

echo -e "profiles list -verbose -all\n**************************\n\n" > ./IntuneProfiles.txt
profiles list >> .//IntuneProfiles.txt

echo -e "profiles show\n**************************\n\n" > ./IntuneProfiles.txt
profiles show >> .//IntuneProfiles.txt

echo -e "profiles show -all -verbose\n**************************\n\n" > ./IntuneProfiles.txt
profiles show -all -verbose >> .//IntuneProfiles.txt


zip -r $ODCFILENAME ./IntuneProfiles.txt

#######################################################################################
# mdmclient commands
#
echo -e "/usr/libexec/mdmclient QueryInstalledProfiles\n**************************\n\n" > ./QueryInstalledProfiles.txt
/usr/libexec/mdmclient QueryInstalledProfiles >> ./QueryInstalledProfiles.txt
zip -r $ODCFILENAME ./QueryInstalledProfiles.txt


echo -e "/usr/libexec/mdmclient QueryCertificates\n**************************\n\n" > ./QueryCertificates.txt
/usr/libexec/mdmclient QueryCertificates >> ./QueryCertificates.txt
zip -r $ODCFILENAME ./QueryCertificates.txt

echo -e "/usr/libexec/mdmclient QueryDeviceInformation\n**************************\n\n" > ./QueryDeviceInformation.txt
/usr/libexec/mdmclient QueryDeviceInformation >> ./QueryDeviceInformation.txt
zip -r $ODCFILENAME ./QueryDeviceInformation.txt

echo -e "/usr/libexec/mdmclient QueryInstalledApps\n**************************\n\n" > ./QueryInstalledApps.txt
/usr/libexec/mdmclient QueryInstalledApps >> ./QueryInstalledApps.txt
zip -r $ODCFILENAME ./QueryInstalledApps.txt

echo -e "/usr/libexec/mdmclient QuerySecurityInfo\n**************************\n\n" > ./QuerySecurityInfo.txt
/usr/libexec/mdmclient QuerySecurityInfo >> ./QuerySecurityInfo.txt
zip -r $ODCFILENAME ./QuerySecurityInfo.txt

echo -e "/usr/libexec/mdmclient dumpSCEPVars\n**************************\n\n" > ./dumpSCEPVars.txt
/usr/libexec/mdmclient dumpSCEPVars >> ./dumpSCEPVars.txt
zip -r $ODCFILENAME ./dumpSCEPVars.txt

if [ -f /usr/local/jamf/bin/jamfAAD ]; then
	echo -e "/usr/local/jamf/bin/jamfAAD gatherAADInfo\n\n\n" > ./jamfAAD-gatherAADInfo.txt
	/usr/local/jamf/bin/jamfAAD gatherAADInfo  >> ./jamfAAD-gatherAADInfo.txt
else
	echo -e "/usr/local/jamf/bin/jamfAAD not found, skipping JAMF" >> ./jamfAAD-gatherAADInfo.txt
fi

#######################################################################################
# Process info
#
echo -e "ps -A -o pid,comm,args\n**************************\n\n" > ./Processes.txt
ps -A -o pid,comm,args >> ./Processes.txt

echo -e "ps -A\n**************************\n\n" >> ./Processes.txt
ps -A >> ./Processes.txt
zip -r $ODCFILENAME ./Processes.txt

echo "last reboot\n************************************\n\n" > ./Reboot_History.txt
last reboot > ./Reboot_History.txt
zip -r $ODCFILENAME ./Reboot_History.txt

echo "last\n************************************\n\n" > ./Last_Output.txt
last > ./Last_Output.txt
zip -r $ODCFILENAME ./Last_Output.txt

# cleanup
rm ./SystemReport.spx
rm ./*.txt
rm ./*.log

# display window in Finder
open .
# return to original path
popd
