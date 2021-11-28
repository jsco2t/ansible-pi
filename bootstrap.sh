#!/bin/bash

if [[ "$1" == "" ]] 
then
    echo "[ERROR] input parameter must be the parent directory for the repository"
    exit 1
fi

if [[ ! -d "$1" ]]
then
    echo "[INFO] repository directory does not exist, creating it"
    sudo mkdir -p "$1"
    sudo chgrp users "$1"
    sudo chmod 775 "$1"

    if [[ "$?" != "0" ]]
    then
        echo "[ERROR] failed creating source directory"  	
        exit $?
    fi
fi

echo "[INFO] installing dependencies"

ansible_sources_file="/etc/apt/sources.list.d/ansible.list"
if [[ ! -f "$ansible_sources_file" ]]; then
    sudo cat "deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main" > "$ansible_sources_file"
fi

sudo apt update && sudo apt install -y software-properties-common python3-pip

if [[ $(apt-key list 93C4A3FD7BB9C367) == "" ]]
then 
    echo "[INFO] installing ansible apt gpg key"
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
    
    if [[ "$?" != "0" ]]
    then
        "[ERROR] failed adding ansible apt gpg key, check /etc/resolv.conf for valid NAMESERVER entry"
        exit $?
    fi
else
    echo "[INFO] ansible apt gpg key is already installed, skipping key install..."
fi

sudo apt update && sudo apt install -y git ansible

# clone repo:
cd "$1"

if [[ ! -d "$1/ansible-pi" ]]
then
    git clone https://github.com/jsco2t/ansible-pi.git
fi

sudo chgrp -R users ./ansible-pi
sudo chmod 775 ./ansible-pi
cd ansible-pi
git pull
