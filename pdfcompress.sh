#!/bin/bash

error() { 
	printf "$1" 
	exit 1 
}

([ $# -eq 0 ] || [ $# -ge 3 ] ) && error "You need to input a file";

infile="$1"
outfile="output.pdf"
[ $# -eq 2 ] && outfile="$2" 

gs \
	-sDEVICE=pdfwrite \
	-dCompatibilityLevel=1.4 \
	-dNOPAUSE -dQUIET -dBATCH \
	-sOutputFile="$outfile" \
	"$infile"

