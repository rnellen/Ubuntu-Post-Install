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
apt-get update -y 

# Upgrade the system
apt-get upgrade -y

# Install various tools
apt-get install mc screen htop nano -y

# Install OpenSSH
apt-get install openssh-server -y

# Backup SSH config files
mv /etc/ssh/ssh_config /etc/ssh/ssh_config-orig
mv /etc/ssh/sshd_config /etc/ssh/sshd_config-orig
#mv /etc/ssh/moduli /etc/ssh/moduli-orig

# Create new SSH config files (disable root login, keybased login, hardening)
echo -n "" > /etc/ssh/ssh_config
echo "Host *" >> /etc/ssh/ssh_config
echo "    PasswordAuthentication no" >> /etc/ssh/ssh_config
echo "    ChallengeResponseAuthentication no" >> /etc/ssh/ssh_config
echo "    PubkeyAuthentication yes" >> /etc/ssh/ssh_config
echo "    SendEnv LANG LC_*" >> /etc/ssh/ssh_config
echo "    HashKnownHosts yes" >> /etc/ssh/ssh_config
echo "    GSSAPIAuthentication yes" >> /etc/ssh/ssh_config
echo "    HostKeyAlgorithms ssh-ed25519-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ssh-ed25519,ssh-rsa" >> /etc/ssh/ssh_config
echo "    KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256" >> /etc/ssh/ssh_config
echo "    Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr" >> /etc/ssh/ssh_config
echo "	   MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com" >> /etc/ssh/ssh_config

echo -n "" > /etc/ssh/sshd_config
echo "
###########################################
Please provide a new SSH port number
###########################################
"
read sshport
echo "Port $sshport" >> /etc/ssh/sshd_config
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "UsePAM yes" >> /etc/ssh/sshd_config
echo "X11Forwarding yes" >> /etc/ssh/sshd_config
echo "PrintMotd no" >> /etc/ssh/sshd_config
echo "AcceptEnv LANG LC_*" >> /etc/ssh/sshd_config
echo "Subsystem	sftp	/usr/lib/openssh/sftp-server" >> /etc/ssh/sshd_config
echo "Protocol 2" >> /etc/ssh/sshd_config
echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config
echo "HostKey /etc/ssh/ssh_host_ed25519_key" >> /etc/ssh/sshd_config
echo "HostKey /etc/ssh/ssh_host_rsa_key" >> /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "AllowGroups ssh-user" >> /etc/ssh/sshd_config
echo "AuthorizedKeysFile     %h/.ssh/authorized_keys" >> /etc/ssh/sshd_config
echo "KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256" >> /etc/ssh/sshd_config
echo "ChallengeResponsMACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.comeAuthentication no" >> /etc/ssh/sshd_config
echo "Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr" >> /etc/ssh/sshd_config
echo "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com" >> /etc/ssh/sshd_config

#ssh-keygen -G /etc/ssh/moduli.all -b 4096
#ssh-keygen -T /etc/ssh/moduli.safe -f /etc/ssh/moduli.all
#mv /etc/ssh/moduli.safe /etc/ssh/moduli
#rm /etc/ssh/moduli.all

awk '$5 > 2000' /etc/ssh/moduli > "${HOME}/moduli"
mv "${HOME}/moduli" /etc/ssh/moduli

# Create new default user and add it to sudo and ssh-user 
echo "
###########################################
Please provide a new user
###########################################
"
read user
adduser $user
usermod -a -G sudo $user
groupadd ssh-user
usermod -a -G ssh-user $user

# Import public key from GitHub
ssh-import-id -u $user gh:rnellen

# Restart sshd
systemctl restart sshd



exit 0
