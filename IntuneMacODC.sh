#! /bin/bash
 
zip -r IntuneMacODC.zip ~/Library/Logs/Company\ Portal/*
zip -r IntuneMacODC.zip ~/Library/Logs/Microsoft/Intune
zip -r IntuneMacODC.zip /var/log/*
zip -r IntunemacODC.zip /Library/Logs/Microsoft/Intune

# pkg utilities
#
#

pkgutil --pkgs > ./pkgutil_pkgs.txt
pkgutil --pkgs | while read x; do (pkgutil --pkg-info $x; echo ""); done > ./pkgutil_info.txt

zip -r IntuneMacODC.zip ./pkgutil_pkgs.txt
zip -r IntuneMacODC.zip ./pkgutil_info.txt


open .
