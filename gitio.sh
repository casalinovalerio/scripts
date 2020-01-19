#!/usr/bin/env sh

################################################################################
# Author		: Valerio Casalino
# Description		: This script shorten any github url with 
# 			  git.io/<something> (even that you can choose)
################################################################################

error() { printf "%s\\n" "$1"; exit 1; }

usage() {
	cat <<-EOF
	Usage: $( basename $0 ) https://github.com/<anything> -c <args>
	
	-h	:print this helpful usage

	-c	:custom string after the slash

	Outputs https://git.io/<some-short-string>
	EOF
}

while getopts "hc:" opt; do
	case $opt in
		h)
			usage
			exit 0
			;;
		c)
			[ -n "$cust" ] && error "Custom string already defined"
			cust="$OPTARG"
			;;
		*)
			[ -n "$url" ] && error "Unexpected input"
			url="$OPTARG"
			;;
	esac
done

[ -z "$cust" ] && { \
	curl -is https://git.io \
		-F "url=$url" \
	| grep "Location:" \
	| cut -d' ' -f2 \
	|| error "Invalid Github url or no internet connection"; }
[ -n "$cust" ] && { \
	curl -is https://git.io \
                -F "url=$url" \
		-F "code=$cust"
        | grep "Location:" \
        | cut -d' ' -f2 \
        || error "Invalid Github url or no internet connection"; }
