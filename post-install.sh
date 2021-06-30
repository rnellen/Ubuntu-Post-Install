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
apt-get install mc screen htop nano ssh-import-id unzip -y

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
echo '%sudo ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Install and configure Firewall
apt-get install ufw -y
ufw default deny incoming
ufw default allow outgoing
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow $sshport/tcp
ufw enable
systemctl enable ufw
systemctl start ufw

# Install and config Fail2Ban
apt-get install fail2ban -y

echo "
[sshd]
enabled = true
port = $sshport
filter = sshd
logpath = /var/log/auth.log
maxretry = 4
bantime = 3600
" >> /etc/fail2ban/jail.local

systemctl enable fail2ban
systemctl start fail2ban

# Motd

# Config and start timesyncd
echo "
NTP=0.pool.ntp.org 1.pool.ntp.org
FallbackNTP=ntp.ubuntu.com
" >> /etc/systemd/timesyncd.conf

sudo systemctl restart systemd-timesyncd.service

# SpeedTest Install

# Option install rclone
echo "
###############################################
Do you want to install rclone? Select yes or no
###############################################
"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip
              unzip rclone-current-linux-amd64.zip
              cd rclone-*-linux-amd64
              cp rclone /usr/bin/
              chown root:root /usr/bin/rclone
              chmod 755 /usr/bin/rclone; break;;
        No ) break;;
    esac
done

# Option install docker and docker-compose
echo "
###############################################
Do you want to install docker? Select yes or no
###############################################
"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) apt install apt-transport-https ca-certificates curl software-properties-common -y
              curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
              add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
              apt update -y
              apt-cache policy docker-ce
              apt install docker-ce -y
              apt install docker-compose -y 
              usermod -a -G docker $user
        			   docker -v
			           # Install Docker-ctop
              echo "deb http://packages.azlux.fr/debian/ buster main" | sudo tee /etc/apt/sources.list.d/azlux.list
              wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -
              apt update
              apt install docker-ctop -y; break;;
        No ) break;;
    esac
done

# Cleanup
sudo apt autoremove
sudo apt clean

exit 0
