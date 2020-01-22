#!/usr/bin/env sh

################################################################################
# Author		: Valerio Casalino
# Description		: This script shorten any github url with 
# 			  git.io/<something> (even that you can choose)
################################################################################

error() { printf "%s\\n" "$1"; exit 1; }

usage() {
	cat <<-EOF
	Usage: $( basename $0 ) https://github.com/<anything> (opt: -c custom)
	
	Outputs https://git.io/(<some-short-string> or <custom>)
	EOF
}

[ $# -lt 1 ] && error "You need 1 input (Github) url"

while [ "$#" -ne 0 ]; do
	case $1 in
		-c)
			[ -n "$code" ] && error "code already defined"
			shift
			code="$1"
			[ "$#" -eq 0 ] || shift
			;;
		*)
			[ -n "$url" ] && error "Url already defined"
			url="$1"
			[ "$#" -eq 0 ] || shift
			;;
	esac
done

[ -z "$code" ] && \
	out=$( curl -is https://git.io -F "url=$url" \
		| grep "Location:" \
		| cut -d' ' -f2 \
		|| error "No internet connection" )
[ -n "$code" ] && \
	out=$( curl -is https://git.io -F "url=$url" -F "code=$code" \
		| grep "Location:" \
		| cut -d' ' -f2 \
		|| error "No internet connection" )

[ -z "$out" ] && error "Invalid Github url or invalid code"
printf "%s\\n" "$out" 
