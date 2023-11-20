#!/usr/bin/env bash

if [[ $1 == "-Debug" || $1 == "-debug" || $1 == "-d" || $1 == "-D"  ]]
        then 
	    set -x
	    echo "Debug mode enabled"
fi

HOSTNAME=`scutil --get LocalHostName`
NOW=`date +%Y-%m-%dT%H-%M-%S%z`
ODCFILENAME="$HOSTNAME-IntuneMacODC-$NOW.zip"

if [ "$EUID" -ne 0 ]
    then echo -e "Please run using 'sudo ./IntuneMacODC.sh'"
    exit
fi

echo "Creating odc working directory"
if [ ! -d odc ]
	then mkdir odc
else
	RAND=$[ $RANDOM % 99999 + 100000 ]
	mv odc odc_$RAND
	mkdir odc
fi
pushd .
cd odc

echo -e "************************\n" > ./sw_vers.txt
echo -e "sw_vers \n\n"              >> ./sw_vers.txt
sw_vers                             >> ./sw_vers.txt
zip -r $ODCFILENAME ./sw_vers.txt

echo -e "************************\n" > ./uname_a.txt
echo -e "uname -a\n\n"              >> ./uname_a.txt
uname -a                            >> ./uname_a.txt
zip -r $ODCFILENAME ./uname_a.txt

echo -e "************************\n"  > ./profiles.txt
echo -e "profiles status\n\n"        >> ./profiles.txt
profiles status                      >> ./profiles.txt
profiles status -output stdout-xml    > ./profiles_status.xml

echo -e "************************\n" >> ./profiles.txt
echo -e "profiles list\n\n"          >> ./profiles.txt
profiles list                        >> ./profiles.txt
profiles list -output stdout-xml      > ./profiles_list.xml

echo -e "************************\n" >> ./profiles.txt
echo -e "profiles show\n\n"          >> ./profiles.txt
profiles show                        >> ./profiles.txt
profiles show  -output stdout-xml     > ./profiles_show.xml

echo -e "************************\n" >> ./profiles.txt
echo -e "profiles list -verbose\n\n" >> ./profiles.txt
profiles list -verbose               >> ./profiles.txt
profiles list -verbose -output stdout-xml  > ./profiles_list_verbose.xml

echo -e "************************\n" >> ./profiles.txt
echo -e "profiles show -verbose\n\n" >> ./profiles.txt
profiles show -verbose               >> ./profiles.txt
profiles show -verbose -output stdout-xml   > ./profiles_show_verbose.xml

zip -r $ODCFILENAME ./profiles.txt
zip -r $ODCFILENAME ./profiles*.xml

echo "Collecting logs"
# Gather log directories 
zip -r $ODCFILENAME ~/Library/Logs/Company\ Portal/*
zip -r $ODCFILENAME ~/Library/Logs/Microsoft/*
zip -r $ODCFILENAME /var/log/*
zip -r $ODCFILENAME /Library/Logs/Microsoft/*
zip -r $ODCFILENAME /Library/Application\ Support/Microsoft/Intune/SideCar
zip -r $ODCFILENAME ~/Library/Containers/com.microsoft.CompanyPortalMac.ssoextension/Data/Library/Caches/Logs/Microsoft/SSOExtension
zip -r $ODCFILENAME /Library/Application\ Support/Microsoft/EdgeUpdater/updater.log*
zip -r $ODCFILENAME /Library/Application\ Support/com.apple.TCC/MDMOverrides.plist


if [ -d /usr/local/jamf/bin/jamfAAD ]; then
     zip -r $ODCFILENAME /usr/local/jamf/bin/jamfAAD/*
else 
	echo "No JAMF folder found. Skipping."
fi

zip -r $ODCFILENAME ~/Library/Logs/DiagnosticReports/* -x "*Siri*"

# MDE attach scenario
if ! type mdatp > /dev/null; then
    echo -e "Defender not installed. Skipping tests."
else 
     zip -r $ODCFILENAME  /Library/Logs/Microsoft/Defender/wdavstate/*
     zip -r $ODCFILENAME  /Library/Logs/Microsoft/Defender/security_management/policy/*
     zip -r $ODCFILENAME  /Library/Logs/Microsoft/Defender/security_management/current_report/*

     echo -e "************************\n" > ./mdatp_health.txt
     echo -e "mdatp health\n\n" >> ./mdatp_health.txt
     mdatp health >> ./mdatp_health.txt
     zip -r $ODCFILENAME ./mdatp_health.txt
fi

# pkg utilities
#
#
echo -e "************************\n"  > ./pkgutil_pkgs.txt
echo -e "pkgutil --pkgs \n\n"        >> ./pkgutil_pkgs.txt
pkgutil --pkgs                       >> ./pkgutil_pkgs.txt

echo -e "************************\n"                   > ./pkgutil_info.txt
echo -e "pkgutil --pkg-info <package name\n\n"        >> ./ppkgutil_info.txt
pkgutil --pkgs | grep -v com.apple.pkg.MAContent10 | sort | while read x; do (pkgutil --pkg-info $x; echo -e ""); done >> ./pkgutil_info.txt

zip -r $ODCFILENAME ./pkgutil_pkgs.txt
zip -r $ODCFILENAME ./pkgutil_info.txt

echo "Gathering syslogs.  This may take a few minutes."

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
rm ./profiles*.xml

# display window in Finder
open .
# return to original path
popd
