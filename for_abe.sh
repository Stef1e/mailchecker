#!/bin/bash
 2
 3 # Define text colors
 4 RED='\033[0;31m'
 5 GREEN='\033[0;32m'
 6 YELLOW='\033[1;33m'
 7 NC='\033[0m' # No Color
 8
 9 # Check if sudo
10 if [ "$EUID" -ne 0 ]; then
11     echo -e "${RED}This script is required to be ran with sudo privileges!${NC}" 1>&2
12     exit 1
13 fi
14
15 echo "Running cPanel Mail Status Probe"
16
17 sleep 1
18
19 /usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --auth --conf --rbl --all --verbose --rude --queue --maillog
20
21 read -p "Would you also like to check the domains? (y|n)" answer
22
23 case $answer in
24     yes|y)
25         for accts in $(whmapi1 listaccts | grep domain | awk '{print $2}'); do
26         echo "_______________________________________________________________________________________"
27             /usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --domain="$accts";
28         echo "_______________________________________________________________________________________"
29         done
30         ;;
31     no|n)
32         exit 0
33         ;;
34 esac
35
