#! /bin/bash

if [ "$EUID" -ne 0 ]
  then echo -e "Please run using 'sudo ./IntuneMacODC.sh'"
  exit
fi

mkdir odc
cd odc

sw_vers > ./sw_vers.txt
zip -r IntuneMacODC.zip ./sw_vers.txt

uname -a > ./uname_a.txt
zip -r IntuneMacODC.zip ./uname_a.txt

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

zip -r IntuneMacODC.zip ./profiles.txt

# Gather log directories 
zip -r IntuneMacODC.zip ~/Library/Logs/Company\ Portal/*
zip -r IntuneMacODC.zip ~/Library/Logs/Microsoft/*
zip -r IntuneMacODC.zip /var/log/*
zip -r IntunemacODC.zip /Library/Logs/Microsoft/*
zip -r IntunemacODC.zip /usr/local/jamf/bin/jamfAAD/*
zip -r IntunemacODC.zip ~/Library/Logs/DiagnosticReports/*

# pkg utilities
#
#

pkgutil --pkgs > ./pkgutil_pkgs.txt
pkgutil --pkgs | while read x; do (pkgutil --pkg-info $x; echo -e ""); done > ./pkgutil_info.txt

zip -r IntuneMacODC.zip ./pkgutil_pkgs.txt
zip -r IntuneMacODC.zip ./pkgutil_info.txt


# Syslogs
log show --style syslog --info --debug --predicate 'process CONTAINS[c] "downloadd" ' --last 30d  >> ./syslog_downloadd.log
zip -r IntuneMacODC.zip ./syslog_downloadd.log

log show --style syslog --info --debug  --predicate 'process BEGINSWITH "Intune" || process CONTAINS[c] "appstore" || process CONTAINS[c] "downloadd" || process CONTAINS "mdm" ' --last 30d  >> ./syslog_intune.log
zip -r IntuneMacODC.zip ./syslog_intune.log

if [ -f /usr/local/jamf/bin/jamfAAD ]; then
	log show -style syslog --info --debug --predicate 'subsystem CONTAINS "jamfAAD"' --last 30d >> ./syslog_jamfAAD.log
	zip -r IntuneMacODC.zip ./syslog_jamfAAD.log
else
	echo -e "/usr/local/jamf/bin/jamfAAD not found, skipping JAMF" >> ./syslog_jamfAAD.log
fi


#######################################################################################
# System Report - double-click to open utility
#

/usr/sbin/system_profiler -detailLevel full -xml > ./SystemReport.spx 2>/dev/null
zip -r IntuneMacODC.zip ./SystemReport.spx

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


zip -r IntuneMacODC.zip ./IntuneProfiles.txt

#######################################################################################
# mdmclient commands
#
echo -e "/usr/libexec/mdmclient QueryInstalledProfiles\n**************************\n\n" > ./QueryInstalledProfiles.txt
/usr/libexec/mdmclient QueryInstalledProfiles >> ./QueryInstalledProfiles.txt
zip -r IntuneMacODC.zip ./QueryInstalledProfiles.txt


echo -e "/usr/libexec/mdmclient QueryCertificates\n**************************\n\n" > ./QueryCertificates.txt
/usr/libexec/mdmclient QueryCertificates >> ./QueryCertificates.txt
zip -r IntuneMacODC.zip ./QueryCertificates.txt

echo -e "/usr/libexec/mdmclient QueryDeviceInformation\n**************************\n\n" > ./QueryDeviceInformation.txt
/usr/libexec/mdmclient QueryDeviceInformation >> ./QueryDeviceInformation.txt
zip -r IntuneMacODC.zip ./QueryDeviceInformation.txt

echo -e "/usr/libexec/mdmclient QueryInstalledApps\n**************************\n\n" > ./QueryInstalledApps.txt
/usr/libexec/mdmclient QueryInstalledApps >> ./QueryInstalledApps.txt
zip -r IntuneMacODC.zip ./QueryInstalledApps.txt

echo -e "/usr/libexec/mdmclient QuerySecurityInfo\n**************************\n\n" > ./QuerySecurityInfo.txt
/usr/libexec/mdmclient QuerySecurityInfo >> ./QuerySecurityInfo.txt
zip -r IntuneMacODC.zip ./QuerySecurityInfo.txt

echo -e "/usr/libexec/mdmclient dumpSCEPVars\n**************************\n\n" > ./dumpSCEPVars.txt
/usr/libexec/mdmclient dumpSCEPVars >> ./dumpSCEPVars.txt
zip -r IntuneMacODC.zip ./dumpSCEPVars.txt

if [ -f /usr/local/jamf/bin/jamfAAD ]; then
	echo -e "/usr/local/jamf/bin/jamfAAD gatherAADInfo\n\n\n" > ./jamfAAD-gatherAADInfo.txt
	/usr/local/jamf/bin/jamfAAD gatherAADInfo  >> ./jamfAAD-gatherAADInfo.txt
else
	echo -e "/usr/local/jamf/bin/jamfAAD not found, skipping JAMF" >> ./jamfAAD-gatherAADInfo.txt
fi

# cleanup
rm ./SystemReport.spx
rm ./*.txt
rm ./*.log

# display window in Finder
open .
