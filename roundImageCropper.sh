#!/bin/bash
# This script round-crops an image using ImageMagick
# If you don't have it, just get it.

error() { printf "$1\n"; exit 1; }

[ $# -ne 1 ] && error "This script needs an Image to work!"
command -v convert > /dev/null || error "Install imagemagick"

newname=$( basename "$1" | cut -d "." -f 1 )"_rounded.png"

convert "$1" -alpha set \
    \( +clone -distort DePolar 0 -virtual-pixel HorizontalTile \
    -background None -distort Polar 0 \) \
    -compose Dst_In -composite -trim +repage "$newname"
