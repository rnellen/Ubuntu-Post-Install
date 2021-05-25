#!/bin/bash

# Goal: Script which automatically sets up a new Ubuntu Machine after installation
# This is a basic install, easily configurable to your needs

# Test to see if user is running with root privileges.
if [[ "${UID}" -ne 0 ]]
then
 echo 'Must execute with sudo or root' >&2
 exit 1
fi

# change root password
passwd

# Ensure system is up to date
sudo apt-get update -y 

# Upgrade the system
sudo apt-get upgrade -y

# Install OpenSSH
sudo apt-get install openssh-server -y

# Backup SSH config files
mv /etc/ssh/ssh_config /etc/ssh/ssh_config-orig
mv /etc/ssh/sshd_config /etc/ssh/sshd_config-orig
mv /etc/ssh/moduli /etc/ssh/moduli-orig

# Create new SSH config files (disable root login, keybased login, hardening)
echo -n "" > /etc/ssh/ssh_config


echo -n "" > /etc/ssh/sshd_config


exit 0
