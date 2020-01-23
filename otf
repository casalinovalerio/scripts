#!/usr/bin/env sh

###############################################################################
# Author	: Valerio Casalino
# Description	: Wrapper for this (https://ki.tc/otf) great service. It is
# 		  a One Time File downloader. You can upload a file as big as
#		  400MB and it will be available for just 1 download.
###############################################################################

error() { printf "\033[31m%s\033[0m\\n" "$1"; exit 1; }
usage(){ printf "Usage: $( basename $0 ) <filename>\\nSimple as that.\\n"; }
check_size()
{
	[ $( du "$1" | awk '{printf $1}' ) -le 409600 ] && return 0
	return 1
}

get_value()
{
	printf "%s" "$2" | grep "$1" | cut -d":" -f2- | sed "s/\"//g;s/,//g"
}

command -v curl > /dev/null || error "You'll need curl."
[ "$#" -eq 1 ] || error "You need only 1 arg: an existing file!"
[ -f "$1" ] || error "The file doesn't exist..."
command -v du > /dev/null && { check_size "$1" || error "File too big"; }

response=$( curl -s -F "file=@$1" https://ki.tc/file/u/ || error "curl fail" )
size=$( get_value "length" "$response" )
name=$( get_value "File Name" "$response" )
cont=$( get_value "Content Type" "$response" )
sha2=$( get_value "sha256" "$response" )
ip25=$( get_value "ip256" "$response" )
link=$( get_value "link" "$response" | tr -d " " )
brow=$( get_value "download_page" "$response" | tr -d " " )

cat <<HERETO
-------------------------------------------------------------------------------
Direct download: 
$link
-------------------------------------------------------------------------------
SIZE>_      $size
FILE NAME>_ $name
CONTENT>_   $cont
SHA256>_    $sha2
IP256>_	    $ip25
-------------------------------------------------------------------------------
To download the file from a webpage in the browser:
$brow
HERETO
