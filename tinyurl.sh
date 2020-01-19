#!/usr/bin/env sh

###############################################################################
# Script name		: tinyurl.sh
# Author		: Valerio Casalino
###############################################################################

error() { printf "%s\\n" "$1"; exit 1; }

usage() 
{
  cat <<-EOF
  Usage: $( basename $0 ) http://example.com
  
  It will return a short link using tinyurl.com service
  EOF  
}
	
[ $# -eq 1 ] || { usage; exit 0;  }

curl "https://tinyurl.com/api-create.php?url=$1" || error "Something is wrong" 
