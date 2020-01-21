#!/usr/bin/env sh
### Author      : Valerio Casalino
### Licence     : GPLv3
### Description : A simple script to download yt videos

install_pkg() {

	pkexec curl \
		-L https://yt-dl.org/downloads/latest/youtube-dl \
		-o /usr/local/bin/youtube-dl && \
		pkexec chmod a+rx /usr/local/bin/youtube-dl 	
}

error() { printf "$1\\n"; exit 1; }

usrname=$( users | head -n 1 )
downloadPath="/home/$usrname/Videos/yt"

command -v youtube-dl || \
	install_pkg "youtube-dl" || \
	error "Impossible to install youtube-dl"

[ "$#" -lt 1 ] && error "Specify URL(s)"

[ -d "$downloadPath" ] || mkdir -p "$downloadPath"

youtube-dl \
	--verbose \
	--restrict-filenames \
	--add-metadata \
	-f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' \
	-o "$downloadPath/$( date -I )-%(title)s.%(ext)s" \
	"$1"	
