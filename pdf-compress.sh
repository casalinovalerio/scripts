#!/usr/bin/env sh

###############################################################################
# Script name		: pdfcompress.sh
# Author		: Valerio Casalino
# Description		: Compress your PDF
###############################################################################

SCRIPT_PATH=$( readlink -f $0 )
SCRIPT_NAME=$( printf "%s" "$SCRIPT_PATH" | xargs basename )
LIB_PATH="$( printf "%s" "$SCRIPT_PATH" | xargs dirname )/lib"
PUBKEY=$( printf "%s/ilovepdf_pubkey" "$LIB_PATH" )

error() { printf "$1\\n" >&2 ; exit 1; }
usage()
{
	cat <<-HERETO
	Script path:
	$SCRIPT_PATH

	Usage: $SCRIPT_NAME [options] <arguments> inputfile.pdf

	-m	Mode: choose the output quality [low, medium, high].
	-i	Input: choose the input file.
	-o	Output: choose the output file name.
	-h	Help: display this message.

	Notes:
	  - If no mode is specified, the medium one will be selected.
	  - This script relies on GhostScript (gs), please install it 
	    before you run this script: https://www.ghostscript.com/download
	    (it is included in many distro's repos by default)
	  - Might produce a larger output than the input...
	HERETO
}

compress()
{
	gs									\
		-q -dNOPAUSE -dBATCH -dSAFER					\
		-sDEVICE=pdfwrite						\
		-dCompatibilityLevel=1.5					\
		-dSimulateOverprint=true					\
		-dPDFSETTINGS=/"$3"						\
		-dEmbedAllFonts=true						\
		-dSubsetFonts=true						\
		-dColorImageDownsampleType=/Bicubic				\
		-dColorImageResolution=150					\
		-dGrayImageDownsampleType=/Bicubic				\
		-dGrayImageResolution=150					\
		-dMonoImageDownsampleType=/Bicubic				\
		-dMonoImageResolution=150					\
		-sOutputFile="$2"						\
		"$1"
}

command -v gs > /dev/null || error "You need gs to run this script"

while getopts "hi:m:o:" opt; do
	case $opt in
		m)
			[ "$OPTARG" = "low" ] && mode="screen"
			[ "$OPTARG" = "medium" ] && mode="ebook"
			[ "$OPTARG" = "high" ] && mode="printer"
			[ -z "$mode" ] && error "$OPTARG is not accepted"
			;;
		i)
			[ ! -f "$OPTARG" ] && error "$OPTARG is not a file!"
			inFile="$OPTARG"
			;;
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
		*)
			usage
			error "Unknown $opt argument"
			;;
	esac
done

[ -z "$inFile" ] && error "You need at least the input file..."
[ -z "$outFile" ] && outFile="$inFile.compressed"
[ -z "$mode" ] && mode="ebook"

compress "$inFile" "$outFile" "$mode"
