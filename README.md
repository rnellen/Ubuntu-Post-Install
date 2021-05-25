# Ubuntu-Bionic-Post-Install
Scripts to Automate Ubuntu 18.04 Post Install

# Why 
- Save time by not having type out all the commands to set yout machine up post install.

- Simplicity / Save time after your install, wget the script raw and let it run.

# Time
- Post installs can take time, especially if you're trying to balance multiple things at once, run the script do something else, reply to that email and finish when its done.

# Whats on each script?
Ubuntu 18.04 post install script

- System updates 
- OpenSSH install
- Ufw config
- speedtest-cli
- Fail2Ban config
- Automatic security updates
- SSH disable root login
- SFTP server config
- Optional install of Wireguard VPN server - credit to https://github.com/l-n-s/wireguard-install
- Optional install for docker
- A message of the day system stats
- System Clean up after the install

# How tu use it
wget https://raw.githubusercontent.com/rnellen/Ubuntu-Bionic-Post-Install/main/post-install.sh && bash post-install.sh

# How tu use speedtest
In order to use speedtest just use "speedtest" as the command in the cli.[ Click for more info.](https://github.com/sivel/speedtest-cli)

# Credits
https://github.com/potts99 (based on his post install script) https://github.com/potts99/Linux-Post-Install
