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
apt-get install mc screen htop nano ssh-import-id -y

# Install OpenSSH
apt-get install openssh-server -y

# Backup SSH config files
mv /etc/ssh/ssh_config /etc/ssh/ssh_config-orig
mv /etc/ssh/sshd_config /etc/ssh/sshd_config-orig

# Create new SSH config files (disable root login, keybased login, hardening)
echo "
Host *
    PasswordAuthentication no
    ChallengeResponseAuthentication no
    PubkeyAuthentication yes
    SendEnv LANG LC_*
    HashKnownHosts yes
    GSSAPIAuthentication yes
    HostKeyAlgorithms ssh-ed25519-cert-v01@openssh.com,ssh-rsa-cert-v01@openssh.com,ssh-ed25519,ssh-rsa
    KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
    Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
    MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com
" >> /etc/ssh/ssh_config

echo "
###########################################
Please provide a new SSH port number
###########################################
"
read sshport
echo "
Port $sshport
PermitRootLogin no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem	sftp	/usr/lib/openssh/sftp-server
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
Protocol 2
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key
PasswordAuthentication no
ChallengeResponseAuthentication no
PubkeyAuthentication yes
AllowGroups ssh-user
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com
AuthorizedKeysFile     %h/.ssh/authorized_keys
" >> /etc/ssh/sshd_config

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
su - $user -c "ssh-import-id gh:rnellen"

# Restart sshd
systemctl restart sshd

# Sudo without password
echo '$user  ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Install and configure Firewall
apt-get install ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow 80
ufw allow 443
ufw allow $sshport
ufw enable

# Fail2Ban

# Motd

# SpeedTest Install

# Docker option install 




exit 0
