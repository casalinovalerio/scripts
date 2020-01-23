#!/usr/bin/env sh

################################################################################
# Author	: Valerio Casalino
# Decription	: Get song lyrics using lyrics.ovh API
################################################################################

error() { printf "\033[31m%s\033[0m\\n" "$1"; exit 1; }

usage()
{
	cat <<-HERETO 
	Usage: $( basename $0 ) <author> <song title>

	Simple as that
	HERETO
}

url_encode()
{
	command -v python3 > /dev/null \
		&& python3 -c "import urllib.parse; print(urllib.parse.quote(input()))" <<< "$1" \
		&& return 0
	command -v python2 > /dev/null \
		&& python2 -c "import urllib;print urllib.quote(raw_input())" <<< "$1" \
		&& return 0
	return 1
}

[ "$#" -ne 2 ] && { usage; error "Error: You need 2 arguments"; }
command -v curl > /dev/null || error "You need curl"
author=$( url_encode "$1" || error "You need Python and urllib" )
songtt=$( url_encode "$2" || error "You need Python and urllib" )

curl -s "https://api.lyrics.ovh/v1/$author/$songtt" \
	| xargs printf \
	| sed "s/{lyrics://g;s/}//g"
