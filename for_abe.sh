#!/bin/bash

# Script Name: cPanel Mail Check
# Author: Steven Fleming
# Created: May 9thth 2024
# Modified: May 9rd 2024
# Version: 1.0

# Define text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

 # Check if sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}This script is required to be ran with sudo privileges!${NC}" 1>&2
    exit 1
fi

echo "Running cPanel Mail Status Probe"

sleep 1

/usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --auth --conf --rbl --all --verbose --rude --queue --maillog

 read -p "Would you also like to check the domains? (y|n)" answer

 case $answer in
    yes|y)
        for accts in $(whmapi1 listaccts | grep domain | awk '{print $2}'); do
        echo "_______________________________________________________________________________________"
            /usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --domain="$accts";
        echo "_______________________________________________________________________________________"
        done
        ;;
    no|n)
        exit 0
        ;;
esac
