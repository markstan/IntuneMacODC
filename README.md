# IntuneMacODC
IntuneMacODC (Intune MacOS One Data Collector) is a support tool to gather system information and logs from MacOS devices managed by Intune.

Run these commands in Terminal to download the script, mark it executable, and launch this tool:

     curl -L https://aka.ms/IntuneMacODC -o IntuneMacODC.sh
     chmod u+x ./IntuneMacODC.sh
     sudo ./IntuneMacODC.sh

When the script completes, a zip file named IntuneMacODC.zip will be created in an ODC sub-folder.  A Finder window will launch to show the contents of the folder.

[Data collected by IntuneMacODC](https://github.com/markstan/IntuneMacODC/DataCollected.md)

# Intune Mac ODC Collection

The **Intune Mac ODC collection captures the following**:

## macOS / Device Information
- macOS version and build using `sw_vers`
- Kernel, architecture, hostname, and OS information using `uname -a`
- Full macOS System Profiler report (`SystemReport.spx`)

## MDM Enrollment and Configuration Profiles
- MDM enrollment/profile status
- Installed configuration profile list
- Detailed configuration profile information
- Verbose profile information
- XML versions of profile status/list/show output
- Installed profiles reported by `mdmclient`

## MDM Device Information
- Device information from `mdmclient QueryDeviceInformation`
- Security information from `mdmclient QuerySecurityInfo`
- Installed applications from `mdmclient QueryInstalledApps`
- Certificates from `mdmclient QueryCertificates`
- SCEP-related variables from `mdmclient dumpSCEPVars`

## Company Portal / Intune Logs
- User-level Company Portal logs from `~/Library/Logs/Company Portal/`
- User-level Microsoft logs from `~/Library/Logs/Microsoft/`
- Microsoft system-level logs from `/Library/Logs/Microsoft/`
- Intune SideCar logs from `/Library/Application Support/Microsoft/Intune/SideCar`

## macOS Unified Logs - Previous 30 Days
- Intune-related processes and messages
- MDM-related processes
- App Store processes
- `downloadd` activity
- Separate `downloadd` log collection

## Apple Push Notification Service (APNs) Logs
- `apsd` process activity
- `apsd`-related event messages
- Previous **30 days** of matching Unified Log entries

## SSO Extension Logs
- Microsoft Company Portal SSO Extension cached logs from the user's container

## Installed Package Information
- List of installed packages using `pkgutil --pkgs`
- Detailed package information using `pkgutil --pkg-info`

## Installed Application Inventory
- Application information through `mdmclient QueryInstalledApps`
- Additional application/package information through `pkgutil`

## Certificate Information
- Certificates visible to `mdmclient QueryCertificates`

## SCEP Information
- Output of `mdmclient dumpSCEPVars`

## Microsoft Defender for Endpoint Information

When `mdatp` is installed, the collection includes:

- Defender `wdavstate` logs/data
- Security Management policy data
- Security Management current-report data
- Output from `mdatp health`
- If `mdatp` is unavailable, the script skips these collections

## JAMF / jamfAAD Information

When `jamfAAD` is present, the collection includes:

- Contents under `/usr/local/jamf/bin/jamfAAD/`
- 30 days of Unified Logs matching the `jamfAAD` subsystem
- Output from `jamfAAD gatherAADInfo`
- These portions are skipped when `jamfAAD` is not present

## Diagnostic Reports
- User DiagnosticReports from `~/Library/Logs/DiagnosticReports/`
- Siri-related reports are excluded

## General macOS Logs
- Contents under `/var/log/`

## Microsoft Edge Updater Information
- `updater.log*` from Microsoft Edge Updater

## TCC / Privacy-Management Information
- `/Library/Application Support/com.apple.TCC/MDMOverrides.plist`

## Running Process Information
- All running processes
- Process IDs
- Commands/process names
- Process arguments via `ps -A -o pid,comm,args`

## Restart / Reboot History
- Output from `last reboot`

## Login / Session History
- Output from `last`

## Output Packaging
- Collected artifacts are placed into a ZIP file using the following naming format: `MacHostName-IntuneMacODC-Timestamp.zip`
