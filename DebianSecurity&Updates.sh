#!/bin/bash

# Debian Configuration and Updater version 1.1
# This script is intended for use in Debian Linux Installations
# Thanks to Pashapasta for the script template, check out the Kali version at https://github.com/PashaPasta/KaliUpdater/blob/master/KaliConfigAndUpdate.sh
# Please contact dteo827@gmail.com with bugs or feature requests

printf "

                    #############################
                    # Debian Security & Updates #
                    #############################

    ##############################################################
    # Welcome, you will be presented with a few questions, please#
    #          answer [y/n] according to your needs.             #
    ##############################################################\n\n"



# Questions function
function questions() {
read -p "Do you want to add Google DNS (8.8.8.8) to the resolv.conf file? [y/n]" answerGoogleDNS
read -p "Do you want to turn off root login, Ipv6, keep boot as read only,and ignore ICMP broadcast requests? [y/n]" answerWegettinghard
read -p "Do you want to install updates to Debian Linux now? [y/n] " answerUpdate
read -p "Do you want to install Bastille [y/n]" answerBastille
read -p "Do you want to install Fail2ban [y/n]" answerFail2ban
read -p "Do you want to install Curl [y/n]" answerCurl
read -p "Do you want to setup OpenVAS? (Note: You will be prompted to enter a password for the OpenVAS admin user, this process may take up to an hour) [y/n] " answerOpenVAS
read -p "Do you want to update Nikto's definitions? [y/n] " answerNikto
read -p "Do you want to install PHP5? [y/n] " answerPhp
read -p "Do you want to install Mysql? [y/n]" answerMysql
read -p "Do you want to download (not install) Leopard Flower [y/n]" answerLeopardFlower
}

# Flags!!!!
# If script run with -a flag, all options will automatically default to yes
# IF script run with -h flag, README.md will be displayed

if [[ $1 = -a ]] ; then

    read -p "Are you sure you want to install all packages and configure everything by default? [y/n] " answerWarning
    if [[ $answerWarning = y ]] ; then
        answerGoogleDNS=y
        answerWegettinghard=y
        answerUpdate=y
        answerBastille=y
        answerFail2ban=y
        answerOpenVAS=y
        answerCurl=y
        answerNikto=y
        answerPhp=y
        answerMysql=y
        answerLeopardFlower=y
    else
        printf "Verify would you do an do not want done...."
        sleep 2
        questions
fi

elif [[ $1 = -h ]] ; then

    cat README.md
    exit
else

    questions
fi

# Logic for update and configuration steps

if [[ $answerGoogleDNS = y ]] ; then

    echo nameserver 8.8.8.8 >> /etc/resolv.conf
fi

if [[ $answerWegettinghard = y]] ; then
    printf " type 'PermitRootLogin no'"
    nano /etc/ssh/sshd_config
    printf " type NETWORKING_IPV6=no "
    printf "IPV6INIT=no"
    nano /etc/sysconfig/network
    echo LABEL=/boot     /boot     ext2     defaults,ro     1 2 >> /etc/fstab
    echo Ignore ICMP request: >> /etc/sysctl.conf
    echo net.ipv4.icmp_echo_ignore_all = 1 >> /etc/sysctl.conf
    echo Ignore Broadcast request: >> /etc/sysctl.conf
    echo net.ipv4.icmp_echo_ignore_broadcasts = 1 >> /etc/sysctl.conf
    sysctl -p
fi

if [[ $answerUpdate = y ]] ; then

    printf "Updating Debain, this stage may take about an hour to complete...Hope you have some time to burn...
    "
    apt-get update -qq && apt-get -y upgrade -qq && apt-get -y dist-upgrade -qq
fi

if [[ $answerBastille = y ]] ; then
    sudo apt-get install bastille perl-tk
fi

if [[ $answerFail2ban = y ]] ; then
    apt-get install fail2ban
fi

if [[ $answerOpenVAS = y ]] ; then
    echo "deb http://download.opensuse.org/repositories/security:/OpenVAS:/UNSTABLE:/v5/Debian_6.0/ ./" >> /etc/apt/sources.list
    apt-key adv --keyserver hkp://keys.gnupg.net --recv-keys BED1E87979EAFD54
    apt-get -y install greenbone-security-assistant gsd openvas-cli openvas-manager openvas-scanner openvas-administrator sqlite3 xsltproc
    apt-get -y install texlive-latex-base texlive-latex-extra texlive-latex-recommended htmldoc
    apt-get -y install alien rpm nsis fakeroot
# not sure about what's below....
    echo ...Starting OpenVAS setup...Please be ready to enter desired OpenVAS admin password

    openvas-setup
    openvas-setup --check-install > /root/Desktop/openvas-info.txt
    openvas-nvt-sync
    openvas-feed-update
fi

if [[ $answerCurl = y ]] ; then
    apt-get install curl
fi

if [[ $answerNikto = y]] ; then
    wget https://www.cirt.net/nikto/nikto-2.1.5.tar.bz2
    tar zxvf nikto-2.1.5.tar.bz2
    printf " To start Nikto run 'cd nikto-2.1.4' and 'perl nikto.pl'
    "
fi

if [[ $answerPhp = y]] ; then
    apt-get install php5-mysql
fi

if [[ $answerMysql = y]] ; then
    apt-get install mysql-server
fi

if [[ $answerLeopardFlower = y ]] ; then
    wget http://iweb.dl.sourceforge.net/project/leopardflower/Source/lpfw-0.4-src.zip
fi

# Not sure about this part
# If OpenVAS was installed, check for error file, if present, print alert

function filecheck () {
    file="/root/Desktop/openvas-info.txt"

    if [ -f "$file" ] ; then
        printf "Check /root/Desktop/openvas-info.txt for errors and recommendations
        "
    fi
}
if [[ $answerOpenVAS = y ]] ; then

file="/root/Desktop/openvas-info.txt"

    filecheck
    printf "Note: OpenVAS user name is [admin]
    "
    sleep 3
fi

function pause () {
        read -p "$*"
}

pause '
    Press [Enter] key to exit...
     '
