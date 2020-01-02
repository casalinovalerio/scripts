#!/usr/bin/env sh

###############################################################################
# Script name		: url-shortener.sh
# Author		: Even a monkey could do it
###############################################################################

[ $# -eq 1 ] || { printf "One url at a time please...\\n"; exit 1; }

curl "https://tinyurl.com/api-create.php?url=$1"
