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
	cat <<WHERETO
	Script path:
	$SCRIPT_PATH

	Usage: $SCRIPT_NAME [options] <arguments> inputfile.pdf

	-m	Mode: choose the output quality [low, medium, high, net].
	-i	Input: choose the input file.
	-o	Output: choose the output file name.
	-h	Help: display this message.

	Notes:
	  - Mode "net" uses the ilovepdf.com APIs.
	  - If no mode is specified, the medium one will be selected.
	  - This script relies on GhostScript (gs), please install it 
	    before you run this script: https://www.ghostscript.com/download
	    (it is included in many distro's repos by default)
	  - Might produce a larger output than the input...
	Todo:
	  - Include ILovePDF's API to compress with curl (?)

WHERETO
}

compress()
{
	gs									\
		-q -dNOPAUSE -dBATCH -dSAFER					\
		-sDEVICE=pdfwrite						\
		-dCompatibilityLevel=1.3					\
		-dSimulateOverprint=true					\
		-dPDFSETTINGS=/"$3"						\
		-dEmbedAllFonts=true						\
		-dSubsetFonts=true						\
		-dAutoRotatePages=/None						\
		-dColorImageDownsampleType=/Bicubic				\
		-dColorImageResolution=150					\
		-dGrayImageDownsampleType=/Bicubic				\
		-dGrayImageResolution=150					\
		-dMonoImageDownsampleType=/Bicubic				\
		-dMonoImageResolution=150					\
		-dPrinted=false							\
		-sOutputFile="$2"						\
		"$1"
}

register_key()
{
	[ ! -d "$LIB_PATH" ] && mkdir -p "$LIBPATH"
	printf "You'll need an account on ilovepdf...\\nEnter your project key: " 
	read -r pubkey
	printf "%s" "$pubkey" > "$PUBKEY"
}

# https://developer.ilovepdf.com/docs/api-reference
ilovepdf()
{
	command -v curl > /dev/null || error "You need curl to use net mode"
	curl -I "http://www.google.com" > /dev/null || error "No internet..."
	[ ! -f "$PUBKEY" ] && register_key
	pubkey=$( cat "$PUBKEY" )
	
	# Get the auth token
	token=$( 								\
		curl 								\
			--data "public_key=$pubkey" 				\
			-X POST 						\
			"https://api.ilovepdf.com/v1/auth" 			\
		| cut -d ":" -f 2 						\
		| cut -d "\"" -f 2						\
	)
	
	# Start the task to the right server
	start=$( 								\
		curl 								\
			-H "Authorization: Bearer $token" 			\
			"https://api.ilovepdf.com/v1/start/compress" 		\
	)
	
	server=$( printf "%s" "$start" | cut -d ":" -f 2 | cut -d "\"" -f 2 )
	task=$( printf "%s" "$start" | cut -d ":" -f 3 | cut -d "\"" -f 2 )
	
	# You need absolute path
	infile=$( readlink -f "$1" )
	baseinfile=$( printf "%s" "$infile" | xargs basename )
	
	# Upload the file to the task
	server_filename=$( 							\
		curl 								\
			-H "Authorization: Bearer $token" 			\
			-F "task=$task" 					\
			-F "file=@$infile" 					\
			"https://$server/v1/upload" 				\
		| cut -d ":" -f 2 						\
		| cut -d "\"" -f 2 						\
	)

	# Start processing the task	
	curl 									\
		-H "Authorization: Bearer $token" 				\
		--data "task=$task"						\
		--data "tool=compress"						\
		--data "files[0][server_filename]=$server_filename"		\
		--data "files[0][filename]=$baseinfile" 			\
		"https://$server/v1/process" > /dev/null
	
	curl 									\
		-H "Authorization: Bearer $token" 				\
		"https://$server/v1/download/$task" > "$2"
		
	curl 									\
		-H "Authorization: Bearer $token" 				\
		-X DELETE 							\
		"https://$server/v1/task/$task"
}

command -v gs > /dev/null || error "You need gs to run this script"

while getopts "hi:m:o:" opt; do
	case $opt in
		m)
			[ "$OPTARG" = "low" ] && mode="screen"
			[ "$OPTARG" = "medium" ] && mode="ebook"
			[ "$OPTARG" = "high" ] && mode="printer"
			[ "$OPTARG" = "net" ] && mode="net"
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

[ "$mode" = "net" ] && ilovepdf "$inFile" "$outFile" && exit 0
compress "$inFile" "$outFile" "$mode"
