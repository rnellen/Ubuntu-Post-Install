#!/bin/bash




# Message of the day 
sudo wget https://raw.githubusercontent.com/jwandrews99/Linux-Automation/master/misc/motd.sh
sudo mv motd.sh /etc/update-motd.d/05-info
sudo chmod +x /etc/update-motd.d/05-info

# Automatic downloads of security updates
sudo apt-get install -y unattended-upgrades
echo "Unattended-Upgrade::Allowed-Origins {
#   "${distro_id}:${distro_codename}-security";
#//  "${distro_id}:${distro_codename}-updates";
#//  "${distro_id}:${distro_codename}-proposed";
#//  "${distro_id}:${distro_codename}-backports";
#Unattended-Upgrade::Automatic-Reboot "true"; 
#}; " >> /etc/apt/apt.conf.d/50unattended-upgrades



# SpeedTest Install
sudo apt-get install speedtest-cli -y

# SFTP Server / FTP server that runs over ssh
echo "
Match group sftp
ChrootDirectory /home
X11Forwarding no
AllowTcpForwarding no
ForceCommand internal-sftp
" >> /etc/ssh/sshd_config

sudo service ssh restart  



# Wireguard install
echo "
######################################################################################################
Would you like to install a wireguard VPN Server? If so enter y / If you dont want to install enter n
######################################################################################################
"
read $vpn

if [[ $vpn -eq "y" ]] || [ $vpn -eq "yes" ]] ; then 
    wget https://raw.githubusercontent.com/l-n-s/wireguard-install/master/wireguard-install.sh -O wireguard-install.sh
    bash wireguard-install.sh

elif  [[ $vpn -eq "n" ]] || [ $vpn -eq "no" ]] ; then 
    echo "Wireguard wasnt installed"
else 
    echo "Error Install Aborted!"
    exit 1
fi



echo "
######################################################################################################
                                        A few tid bits
In order to use SpeedTest - Just use "speedtest" in the cli
Reboot your server to fully configure the vpn service
When using the VPN service on a device simply use the config file in you home directory. 
To create a new config enter  bash wireguard-install.sh in the cli and choose a new name
If you installed Docker a portainer management image is running on ip:9000
######################################################################################################
"

exit 0
