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

	-m	Mode: choose the level of output quality [low, medium, high].
	-i	Input: choose the input file.
	-o	Output: choose the output file name.
	-h	Help: display this message.

	Notes:
	  - If no mode is specified, the medium one will be selected.
	  - This script relies on GhostScript (gs), please install it 
	    before you run this script: https://www.ghostscript.com/download
	    (it is included in many distro's repos by default)

WHERETO
}

compress()
{
	gs						\
		-q -dNOPAUSE -dBATCH -dSAFER		\
		-sDEVICE=pdfwrite			\
		-dCompatibilityLevel=1.3		\
		-dSimulateOverprint=true		\
		-dPDFSETTINGS=/"$3"			\
		-dEmbedAllFonts=true			\
		-dSubsetFonts=true			\
		-dAutoRotatePages=/None			\
		-dColorImageDownsampleType=/Bicubic	\
		-dColorImageResolution=150		\
		-dGrayImageDownsampleType=/Bicubic	\
		-dGrayImageResolution=150		\
		-dMonoImageDownsampleType=/Bicubic	\
		-dMonoImageResolution=150		\
		-dPrinted=false
		-sOutputFile="$2"			\
		"$1"
}

command -v gs || error "You need gs to run this script"

while getopts "hi:m:o:" opt; do
	case $opt in
		m)
			[ "$OPTARG" = "low" ] && mode="screen"
			[ "$OPTARG" = "medium" ] && mode="ebook"
			[ "$OPTARG" = "high" ] && mode="printer"
			[ -z "$mode" ] && error "$OPTARG is not a possible value.."
			;;
		i)
			[ ! -f "$OPTARG" ] && error "$OPTARG is not a file!"
			inFile="$OPTARG"
		o)
			outFile="$OPTARG"
			;;
		h)
			usage
			exit 0
			;;
		:)
			error "Option -$opt requires an argument"
			;;
	esac
done

[ -z "$inFile" ] && error "You need at least the input file..."
[ -z "$outFile" ] && outFile="$inFile.compressed"
[ -z "$mode" ] && mode="ebook"

compress "$inFile" "$outFile" "$mode"
