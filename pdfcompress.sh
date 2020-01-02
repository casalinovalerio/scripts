#!/usr/bin/env sh

###############################################################################
# Script name		: pdfcompress.sh
# Author		: Valerio Casalino
# Description		: Compress your PDF
###############################################################################

SCRIPT_PATH=$( readlink -f $0 )
SCRIPT_NAME=$( printf "$SCRIPT_PATH" | xargs basename )

error() { printf "$1\\n" >&2 ; exit 1; }
usage()
{
	cat <<WHERETO
	Script path:
	$SCRIPT_PATH

	Usage: $SCRIPT_NAME [options] <arguments> inputfile.pdf

	-m	Mode: choose the level of compression between low, medium
		and high, but the higher the level, the higher the time.
	-o	Output: choose the output file name.
	-h	Help: display this message 

WHERETO
}

command -v gs || error "You need gs to run this script"

infile="$1"
outfile="$1.compressed"
quality="72"
tmpfile="$( mktemp )"

[ -z "$infile" ] && error "$0 [infile] (opt)[outfile] (opt)[quality]"
[ ! -z "$2" ] && outfile="$2"
[ ! -z "$3" ] && quality="$3"

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
