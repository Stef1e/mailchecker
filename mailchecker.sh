#!/bin/bash
#
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


msp_auth() { #option 1
    /usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --auth
}

msp_conf() { #option 2
    /usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --conf
}

msp_limit() { #option 3
    local limit_value=$1
    /usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --limit $limit_value
}

msp_logdir() { #option 4
    local logdir_value=$1
    /usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --logdir $logdir_value
}

msp_maillog() { #option 5
    /usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --maillog
}

msp_queue() { #option 6
    /usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --queue
}

msp_rbl() { #option 7
    /usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --rbl --all
}

msp_rotated() { #option 9
    /usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --rotated
}

msp_rude() { #option 10
    /usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --rude
}

msp_threshold() { #option 11
    local threshold_value=$1
    /usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --threshold $threshold_value
}

msp_verbose() { #option 12
    /usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --verbose
}

msp_domain() { #option 13
        local domains=($(whmapi1 listaccts | grep domain | awk '{print $2}'))

    for domain in "${domains[@]}"; do
        echo "$domain"
    done
        read -p "Enter the domain you would like to check:  " domain_choice

    /usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --domain=$domain_choice
}

msp_email() { #option 14
        local emails=($(whmapi1 listaccts | grep -P "[^@ \t\r\n]+@[^@ \t\r\n]+\.[^@ \t\r\n]+" | awk '{print $2}'))

        for email in "$emails[@]}"; do
                echo "$email"
        done
                read -p "Enter the domain you would like to check:   " email_choice

    /usr/local/cpanel/3rdparty/bin/perl <(curl -s "https://raw.githubusercontent.com/CpanelInc/tech-SSE/master/msp.pl") --email=$email_choice
}

clear_exim_queue() { #option 15
    total_queue=$(exim -bpc)
    echo "The Current Email Queue size is: $total_queue"

    read -p "Would you like to clear the exim frozen queue? ({Y}es/{N}o): " response

response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

    case $response in
        yes|y)
                exim -bp | grep frozen | awk '{print $3}' | xargs exim -Mrm
                ;;
        no|n)
                return 0
                ;;
        *)
                echo "Invalid response. Please enter ({Y}es/{N}o)"
                ;;

    esac

    #if [ "$response" = "Yes" ]; then
    #    exim -bp | grep frozen | awk '{print $3}' | xargs exim -Mrm;return 0
    #else
    #    return 0
    #fi
}

#Uses the cPanel MSP.pl script
cpanel_MSP() {
    #read -p "Would you like to run cPanel's MSP script? (Yes/No): " response

    #if [ "$response" = "Yes" ]; then
        while true; do

        echo "Please choose an option below:"
        echo "1. Print mail authentication statistics"
        echo "2. Print mail configuration info"
        echo "3. Limit statistics checks to n results"
        echo "5. Check maillog for common errors"
        echo "7. Check IP's against provided blacklists"
        echo "9. Check rotated exim logs"
        echo "10. Forgo nice/ionice settings"
        echo "11. Limit statistics output to n threshold"
        echo "12. Display all information"
        echo "13. Check for domain's existence, ownership, and resolution on the server"
        echo "15. Clear exim frozen queue"
        read -p "Enter your choice (1-15): " choice

        case $choice in
            1)
                msp_auth
                ;;
            2)
                msp_conf
                ;;
            3)
                read -p "Enter the limit value: (defaults to 10, set to 0 for no limit)" limit_value
                msp_limit $limit_value
                ;;
            5)
                msp_maillog
                ;;
            7)
                msp_rbl
                ;;
            9)
                msp_rotated
                ;;
            10)
                msp_rude
                ;;
            11)
                read -p "Enter the threshold value: " threshold_value
                msp_threshold $threshold_value
                ;;
            12)
                msp_verbose
                ;;
            13)
                #read -p "Enter the domain: " domain_value
                msp_domain $domain_value
                ;;
            15)
                clear_exim_queue
                ;;
            16)
                break
                ;;
            *)
                echo "Invalid choice. Please enter a number between 1 and 15."
                ;;
        esac


        read -p "Do you want to return to the script? ({Y}es/{N}o):  " return_choice
        case $return_choice in
                Yes|yes|Y|y)
                        continue
                ;;
                No|no|n|N)
                        break
                ;;

                *)
                        echo "Invalid Choice. Please enter {Y}es or {N}o."
                ;;
        esac

 #   else
 #      echo "Exiting script."
 #   fi
        done
}


#Main function to start script
main() {
clear
    echo "Please choose an option:"
    echo "1. Run cPanel's MSP script"
    echo "2. Clear exim frozen queue"
    echo "3. Exit"
    read -p "Enter your choice (1-3): " choice

    case $choice in
        1)
            cpanel_MSP
            ;;
        2)
            clear_exim_queue
            ;;
        3)  echo "Exiting script"
                exit 0
            ;;
        *)
            echo "Invalid choice. Please enter 1 - 3."
            ;;
    esac
}

main
