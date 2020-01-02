#!/usr/bin/env sh

########################################################################
# Script name	: crypt.sh 
# Author	: Valerio Casalino
# Licence	: GPLv3
# Description	: Encrypt and decrypt files in terminal
########################################################################

SCRIPT_FULLPATH=$( echo "$0" | xargs readlink -f )
SCRIPT_NAME=$( printf "$SCRIPT_FULLPATH" | xargs basename )

error() { printf "%s\\n" "$1" >&2; exit 1; }

usage() 
{
	cat <<WHERETO
	
	Your installation path:
	$SCRIPT_FULLPATH
	
	Description: An openssl wrapper that you can use to encrypt and 
	             decrypt files.
	
	Usage: $SCRIPT_NAME [options] [-e|-d] <input-file>
	
		-e	Encrypt the input file.
		-d	Decrypt the input file.
		-o	Name the output file, default name is 'out.ecrypt' 
			for option -e, or 'out.dcrypt' for option -d
		-h	Show this usage.
	
	Examples: # You can change the extension too
		$SCRIPT_NAME -e cleartext.txt -o encryptedFile.js
		$SCRIPT_NAME -d ecryptedFile.js

WHERETO
}

encrypt() 
{
	printf "Encrypting %s...\\n" "$1"
	openssl enc -aes-256-cbc -salt -pbkdf2 -in "$1" -out "$2" || error "Something went wrong... Abort."
	printf "File successfully encrypted!\\n"
}

decrypt()
{
	printf "Decrypting %s...\\n" "$1"
	openssl enc -aes-256-cbc -d -pbkdf2 -in "$1" -out "$2" || error "Something went wrong... Abort."
	printf "File successfully decrypted!\\n"
}

command -v openssl > /dev/null || error "You should have openssl installed to proceed..."

while getopts "ho:d:e:" opt; do
	case "$opt" in
		e) 
			[ -n "$flag" ] && error "-e and -d are mutually exclusive."
			flag="e"
			inFile="$OPTARG"
			[ ! -f "$inFile" ] && error "File doesn't exist.'"
			;;
		d)
			[ -n "$flag" ] && error "-e and -d are mutually exclusive."
			flag="d"
			inFile="$OPTARG"
			[ ! -f "$inFile" ] && error "File doesn't exist."
			;;
		o)
			outFile="$OPTARG"
			;;
		h)
			usage
			exit 0
			;;
		:)
        		error "Option -$opt requires an argument."
        		;;
	esac
done

[ -z "$outFile" ] && [ "$flag" = "d" ] && outFile="out.dcrypt"  
[ -z "$outFile" ] && [ "$flag" = "e" ] && outFile="out.ecrypt"
[ "$flag" = "e" ] && encrypt "$inFile" "$outFile"
[ "$flag" = "d" ] && decrypt "$inFile" "$outFile"
