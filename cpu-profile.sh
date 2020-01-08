#!/usr/bin/env sh

################################################################################
# Script name	: cpu-profile.sh 
# Author	: Valerio Casalino
# Description	: Use this script to tweak the power consuption of your laptop
################################################################################

SCRIPT_PATH=$( readlink -f $0 )
SCRIPT_NAME=$( printf "%s" "$SCRIPT_PATH" | xargs basename )
RED="\033[31m"
NCL="\033[0m"

# Available governors
CON="conservative"
PER="performance"
SCH="schedutil"
OND="ondemand"

error() 
{ 
	printf "${RED}E: %s${NCL}\\n" "$1" >&2
	exit 1
}


usage()
{
	cat <<HERETO
Script path:
$SCRIPT_PATH

Usage $SCRIPT_NAME [options] <arguments>

	-f	Frequency: max frequency for all of your cores.
	-c	Cores: how many cores you wish to use. If the
		value exceeds the maximum cores the script
		will just stop without doing anything.
	-g	Governor: choose your CPU governor. Posible
		values are: conservative, performance, 
		schedutil or ondemand.
	-p	Powertop: if do you want to auto tune your
		settings with powertop, you can choose:
		full or nousb (to avoid usb autosuspend).
	-y	Yes: do not prompt for confirmation.
	-h	Help: print this message.

HERETO
}

# args: governor & freqeuncy & cores
confirm()
{	
	printf "Governor: $GOV\\nFrequency: $FRQ\\nCores: $CRS\\n"
	printf "Is it correct? [y/N]: "
	read -r yn
	[ $yn != 'y' ] && [ $yn != 'Y' ] && return 1
}

choose_governor()
{
	printf "Choose governor:\\n1 $CON\\n2 $PER\\n3 $SCH\\n4 $OND\\n"
	read -r choice || return 1
	case $choice in
		1) gov="$CON";;
		2) gov="$PER";;
		3) gov="$SCH";;
		4) gov="$OND";;
		*) return 1  ;;
	esac
	printf "%s" "$gov"
}

choose_frequency()
{
	avail=$( cpufreqctl --frequency --available | tr ' ' '\n' )
	printf "Choose frequency:\\n"
	printf "%s" "$avail" | nl
	read -r choice || return 1
	[ "$choice" -le 0 ] && return 1
	freq=$( printf "%s" "$avail" | tail -n "$choice" | head -n 1 )
	printf "%s" "$freq"
}

choose_cores()
{
	max=$(	find /sys/devices/system/cpu/ 					\
			-maxdepth 1						\
			-name "*cpu[0-9]*"					\
			-type d 						\
		| wc -l )
	printf "Choose core number [max $max]:\\n"
	read -r choice
	{ [ "$choice" -lt 1 ] || [ "$choice" -gt "$max" ]; } && return 1
	printf "%s" "$choice"
}


# Check if cpufrequctl is installed
command -v cpufreqctl || error "You'll need cpufreqctl"

# Print out the driver
DRIVER=$( cpufreqctl --driver )
printf "Using '$DRIVER' driver\\n"

GOV=$( choose_governor ) || error "Failed to get governor"
FRQ=$( choose_frequency ) || error "Failed to get frequency"
CRS=$( choose_cores ) || error "Failed to get cores"

confirmation "$GOV" "$FRQ" "$CRS" || error "Abort."
printf "Applying changes...\\n"


sudo cpufreqctl --governor --set=$govChoice
sudo cpufreqctl --frequency-max --set=$freqChoice
for i in $( seq $nDis $nCpu | tac ); do sudo cpufreqctl --off --core=$i; done

printf "All done!\\nGovernor status:\\n"
cpufreqctl  --governor | tr ' ' '\n' | nl | sed "s/^     /Core#/g" | tr '\t' '-'

printf "Frequency report:\\n"
for i in $( seq 0 $nCpu ); do printf "Core#$i: "; cpufreqctl --frequency --core=$i; done
