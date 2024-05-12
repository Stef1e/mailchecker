#!/bin/bash

# Script Name: cPanel Mail Check
# Author: Steven Fleming
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

#/usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --auth --rotated --conf --verbose --rbl --all --queue --maillog

#Function to check cPanel domains
cp_domains() {
    echo -e "${GREEN}\e[4mDomains detected!\e[0m${NC}"
    echo " "
    sleep 0.25

    whmapi1 listaccts | grep domain | awk '{print $2}'

    sleep 0.25
    echo " "
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
}

#Checks if cPanel domains are present, then will run the function
if [ -n "$(whmapi1 listaccts | grep domain)" ]; then
    cp_domains
else
    exit 0
fi
