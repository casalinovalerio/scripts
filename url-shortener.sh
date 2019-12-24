#!/bin/bash

[ $# -eq 1 ] || exit 1

curl "https://api.casalinovalerio.com/short-url.php?url=$1"
