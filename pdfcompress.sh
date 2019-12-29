#!/bin/bash

error() { printf "$1\\n"; exit 1; }

command -v gs || error "You need gs to run this script"

infile="$1"
tmpfile="$( mktemp )"

[ -z "$infile" ] && error "$0 [infile] (opt)[outfile] (opt)[quality]"

if [ ! -z "$2" ]; then 
	outfile="$2"
else
	outfile="-" #stdout
fi

if [ ! -z "$3" ]; then
	quality="$3"
else
	quality="72"
fi

gs						\
	-q -dNOPAUSE -dBATCH -dSAFER		\
	-sDEVICE=pdfwrite			\
	-dCompatibilityLevel=1.3		\
	-dPDFSETTINGS=/screen			\
	-dEmbedAllFonts=true			\
	-dSubsetFonts=true			\
	-dAutoRotatePages=/None			\
	-dColorImageDownsampleType=/Bicubic	\
	-dColorImageResolution=$quality		\
	-dGrayImageDownsampleType=/Bicubic	\
	-dGrayImageResolution=$quality		\
	-dMonoImageDownsampleType=/Subsample	\
	-dMonoImageResolution=$quality		\
	-sOutputFile="$tmpfile"			\
	"$infile"

[ ! -f "$infile" -o ! -f "$tmpfile" ] && error "No file written"

insize=$( wc -c "$infile" | cut -f1 -d\  )
outsize=$( wc -c "$tmpfile" | cut -f1 -d\ )
[ "$insize" -lt "$outsize" ] && error "Input smaller that output"

mv "$tmpfile" "$outfile"
