#!/usr/bin/env sh

################################################################################
# Author		: Valerio Casalino
# Description		: This script shorten any github url with 
# 			  git.io/<something> (even that you can choose)
################################################################################

error() { printf "%s\\n" "$1"; exit 1; }

usage() {
	cat <<-EOF
	Usage: $( basename $0 ) https://github.com/<anything>
	
	Outputs https://git.io/<some-short-string>
	EOF
}

[ $# -ne 1 ] && error "You need 1 input (Github) url"

out=$( curl -is https://git.io \
	-F "url=$1" \
| grep "Location:" \
| cut -d' ' -f2 \
|| error "No internet connection" ) 

[ -z "$out" ] && error "Invalid Github url"
printf "%s\\n" "$out" 
