#!/usr/bin/env sh
# Author:	Valerio Casalino
# Description:	Making systemd reduce boot time removing server features
# Licence:	GPLv3

error() { printf "E: $1\\n"; exit 1; }
message() { printf "M: $1\\n"; }

# You need to use systemd and run as root
pidof systemd || error "You need systemd! Abort.";
[ $( whoami ) != "root" ] && error "Run as root please"

message "Script location: $( readlink -f $0 )"

# https://askubuntu.com/a/1187165
message "Cleaning systemd journal (see script for info)..."
sudo journalctl --rotate > /dev/null 2>&1
sudo journalctl --vacuum-time=5s > /dev/null 2>&1

# https://wiki.archlinux.org/index.php/Systemd/Journal#Journal_size_limit
message "Setting a limit of 50M on the journal..."
sudo sed -ri \
	"s/#SystemMaxUse=([0-9]{0,}[KMGT]*)/SystemMaxUse=50M/g" \
	/etc/systemd/journald.conf
message "All done."

# https://askubuntu.com/a/1187142
message "Disabling NetworkManager-wait-online (see script for info)..."
sudo systemctl disable NetworkManager-wait-online.service > /dev/null 2>&1
message "Done. Now your boot time should be improved!"

# I want to add more features but i need time
