#!/bin/bash

# Colours
NC='\033[0m' # No Color
Black='\033[0;30m'
DGray='\033[1;30m'
Red='\033[0;31m'
LRed='\033[1;31m'
Green='\033[0;32m'
LGreen='\033[1;32m'
Orange='\033[0;33m'
Yellow='\033[1;33m'
Blue='\033[0;34m'
LBlue='\033[1;34m'
Purple='\033[0;35m'
LPurple='\033[1;35m'
Cyan='\033[0;36m'
LCyan='\033[1;36m'
LGray='\033[0;37m'
White='\033[1;37m'

printf ${LGreen}
echo "========================================================================"
printf "Name	:\tEvil SSH v1.0\n"
echo
printf "Author 	:\tAbdul Noushad Sheikh\n"
echo
printf "Note 	:\tThis script runs parallel ssh shells for selected hosts\n"
printf "\t\tup on same network, having user account with same\n"
printf "\t\tusername and password.\n"
printf "\t\tThis script can cause great disaster if wrong commands\n"
printf "\t\tare run. This is made for educational purpose only.\n"
printf "\n\t\t${LRed}Please use it wisely for constructive purpose :)${LGreen}\n"
echo
printf "Date	:\t" & date
echo "======================================================================="

#The Script

printf "${White}Enter the IP-Addresses : "
read ip_addresses

hosts=(`nmap -sn ${ip_addresses} | grep 'Nmap scan report for ' | cut -f 5 -d' '`)

printf "${LGreen}\nFound ${#hosts[*]} hosts up for ${ip_addresses}\n\n${NC}"

#######  Displaying the IPs of devices up on network  ##### 
printf "${LCyan}Hosts :${Yellow}\n"

for((i=0;i<${#hosts[@]};i++))
do
    echo "$i: ${hosts[$i]}"
done
if [ ${#hosts[@]} -eq 0 ]; then
printf "\n${Yellow}No Hosts Found. Exiting...${NC}\n\n"
exit
fi 

####### Writing hosts in a file my_hosts.txt ##############
echo -n "" > my_hosts.txt
printf "%s\n" "${hosts[@]}" > my_hosts.txt

####### Getting common user details #######################
printf ${LRed}
printf "\nEnter common user name : "
read user_name
echo -e -n "Enter password: "
stty -echo
read password
stty echo
echo
printf ${NC}

######## Authenticating hosts fingerprints ################
printf "${Yellow}\n* Clearing known hosts file..."
echo -n "" > ~/.ssh/known_hosts
printf "${LCyan}\n* Getting known all hosts...\n\n${NC}"
#hosts=$(cat my_hosts.txt)

for ip in $hosts
do
echo $ip
ssh-keyscan -H $ip >> ~/.ssh/known_hosts
done

printf "${Yellow}\nAuthentication with host done. Fingerprints verified.\n${White}"

###### Running comands on all known hosts #################

echo
while true
do
printf "${LGreen}coder-boy@Host-Router${NC}:${LBlue}~${NC}$ "
read shell_cmd
if [ "$shell_cmd" == "exit" ];
then break
fi
/usr/bin/expect <<EOF
spawn pssh -h my_hosts.txt -l $user_name -A -v -P -o evil_results $shell_cmd
expect "*Password:*"
send "${password}\r"
expect eof
EOF
done
printf ${NC}
echo
