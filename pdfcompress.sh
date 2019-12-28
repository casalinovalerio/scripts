#!/bin/bash

error() { printf "$1\\n"; exit 1; }

command -v gs || error "You need gs to run this script"
([ $# -eq 0 ] || [ $# -ge 3 ] ) &&\
       	error "You need to input at least 1 filename";

infile="$1"
outfile="output.pdf" 
[ $# -eq 2 ] && [ "$1" != "$2" ] && outfile="$2"

gs -sDEVICE=pdfwrite \
	-dCompatibilityLevel=1.4 \
	-dNOPAUSE -dQUIET -dBATCH \
	-sOutputFile="$outfile" "$infile"
