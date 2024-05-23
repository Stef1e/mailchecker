#!/bin/bash

# Script Name: cPanel Mail Check
# Author: Steven Fleming
# Created: May 9th 2024
# Modified: May 23rd 2024
# Version: 1.0.2

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

exiwhat | awk -F'listening' '{print "Exim is listening" $2}'

sleep 0.50

echo "  "

#Unused at the moment
#ip=$(curl -sL ipconfig.me)

echo "Running cPanel Mail Status Probe"

sleep 1

/usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --auth --rotated --conf --verbose --rbl --all --maillog

#Function to clear Exim Queue
exim_queue() {
echo -e "${GREEN}\e[4mExim Queue Summary\e[0m${NC}"
     exim -bp | exiqsumm
        echo " "
#    queue_output=$(/usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --queue)
    queue_count=$(exim -bpc)
    echo -e "Exim Queue Count: " "${RED}\e[4m$queue_count\e[0m${NC}"

    if (( queue_count > 10 )); then
        read -r -p "The Exim queue has more than 10 frozen emails. Would you like to clear it? (y/n): " user_input

        if [[ "$user_input" == "y" || "$user_input" == "yes" ]]; then
            exim -bp | grep frozen | awk '{print $3}' | xargs exim -Mrm > /dev/null
            echo "${GREEN}Frozen mail queue cleared!${NC}"
        else
            echo "Mail queue left intact"
                echo "  "
        fi
    fi
}

echo "_______________________________________________________________________________________"

#Function to check cPanel domains
cp_domains() {
    echo -e "${GREEN}\e[4mDomains detected!\e[0m${NC}"
    echo " "
    sleep 0.25

    whmapi1 listaccts | grep domain | awk '{print $2}'

    sleep 0.25
    echo " "
    read -r -p "Would you like to check the domains? (y|n):" answer

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

#Runs exim queue function
exim_queue

#Checks if cPanel domains are present, then will run the function
if whmapi1 listaccts | grep -q domain; then
    cp_domains
else
    exit 0
fi
