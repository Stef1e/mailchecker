#!/bin/bash

# Script Name: cPanel Mail Check
# Author: Stef1e
# Created: May 9thth 2024
# Modified: May 10th 2024
# Version: 1.0.1

#This script utilized the cPanel Mail Status Probe perl script.
#More information can be found at the official Github page below:
#https://github.com/CpanelInc/tech-MSP

# Define text colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}This script is required to be ran with sudo privileges!${NC}" 1>&2
    exit 1
fi

echo "Running cPanel Mail Status Probe"

sleep 1

/usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --auth --conf --rbl --all --verbose --rude --queue --maillog

echo -e "${GREEN}Domains detected!${NC}"

sleep 0.5

whmapi1 listaccts | grep domain | awk '{print $2}'

sleep 0.5

read -p "Would you like to check the domains? (y|n):" answer

case $answer in
    yes|y)
        for accts in $(whmapi1 listaccts | grep domain | awk '{print $2}'); do
        echo "_______________________________________________________________________________________"
            /usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --domain="$accts";
        echo "_______________________________________________________________________________________"
        done
        ;;
    no|n)
        echo -e "${RED}Exiting script...${NC}"
        sleep 0.25
        exit 0
        ;;
esac
