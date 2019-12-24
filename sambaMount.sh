#!/bin/bash

[ $# -ne 4 ] && printf "Usage:\n$0 [server-address/share] [mount-point] [username] [password]"; exit 1

serverAddress="$1"
mountPoint="$2"
usr="$3"
pass="$4"

pkexec mount -t cifs //"$serverAddress" "$mountPoint" -o username="$usr",password="$pass",sec=ntlm,vers=1.0,x-systemd.automount,x-systemd.device-timeout=30,_netdev
