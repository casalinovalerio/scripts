#!/bin/bash
# This script downloads the NASA APOD: https://apod.nasa.gov/apod/astropix.html
# And the BING image of the day: https://www.bing.com/

dwnDir="$HOME/Pictures"
tmpFile=$( mktemp )

# Bing Image of the day: https://stackoverflow.com/a/18096210
curl "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=it-IT" \
	| sed "s/,/\n/g" \
	| grep "\"url\"" \
	| cut -d ":" -f 2 \
	| xargs echo "https://bing.com"$1 \
	| sed "s/ //g" \
	| xargs curl $1 -o $dwnDir/"$(date --rfc-3339='date')-bing.jpg"
	
	
# NASA APOD: https://api.nasa.gov/api.html#apod
url=$(curl "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY" \
	| sed "s/,/\n/g;s/\"//g;s/}//g;s/{//g" \
	| grep "hdurl\|title" \
	| tee $tmpFile \
	| grep hdurl \
	| cut -d ":" -f 2-)

title="$( grep title $tmpFile | cut -d ":" -f 2- | sed "s/ /-/g").jpg"

curl $url -o "$dwnDir/$title"

# Sometimes NASA put a video, in that case it won't be downloaded

rm $tmpFile
