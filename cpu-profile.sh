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

# Check if cpufrequctl is installed
command -v cpufreqctl > /dev/null || error "You'll need cpufreqctl"

# Available governors
CON="conservative"
PER="performance"
SCH="schedutil"
OND="ondemand"

# Available frequencies
AVAIL_FRQ=$( cpufreqctl --frequency --available | tr ' ' '\n' )

# Maximum number of cores
MAX_CORES=$( find /sys/devices/system/cpu/ -maxdepth 1 -name "*cpu[0-9]*" -type d | wc -l )

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
	[ "$yn" != "y" ] && [ "$yn" != "Y" ] && return 1
	return 0
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
	GOV="$gov"
}

choose_frequency()
{
	printf "Choose frequency:\\n"
	printf "%s" "$AVAIL_FRQ" | nl
	read -r choice || return 1
	[ "$choice" -le 0 ] && return 1
	freq=$( printf "%s" "$AVAIL_FRQ" | tail -n "$choice" | head -n 1 )
	FRQ="$freq"
}

choose_cores()
{
	printf "Choose core number [max $MAX_CORES]:\\n"
	read -r choice
	{ [ "$choice" -lt 1 ] || [ "$choice" -gt "$MAX_CORES" ]; } && return 1
	CRS="$choice"
}

# args: mode
enable_powertop()
{
	sudo powertop --auto-tune > /dev/null || error "Error in autotune"
	[ "$1" = "full" ] && return 0
	for i in /sys/bus/usb/devices/*
	do
		target="/sys/bus/usb/devices/$i/power/control"
		[ -f "$target" ] && [ -w "$target" ] && { printf "on\\n"	\
			| sudo tee "$target" > /dev/null 			\
			|| error "E in 'on' for $target"; }
	done
	return 0
}


while getopts "hyf:c:g:p:" opt; do
	case $opt in
		h)
			usage
			exit 0
			;;
		y)
			YES="y"
			;;
		f)
			[ -n "$FRQ" ] && error "Too many frequencies"
			printf "%s" "$AVAIL_FRQ" | grep "$OPTARG" > /dev/null	\
				|| error "Freq $OPTARG not available."
			FRQ="$OPTARG"
			;;
		g)
			[ -n "$GOV" ] && error "Too many governors"
			
			{  [ "$OPTARG" = "$CON" ]				\
			|| [ "$OPTARG" = "$SCH" ]				\
			|| [ "$OPTARG" = "$OND" ]				\
			|| [ "$OPTARG" = "$PER" ];				\
			} && GOV="$OPTARG"
			
			[ -z "$GOV" ] && error "$OPTARG is not accepted."
			;;
		c)
			[ -n "$CRS" ] && error "Too many cores declarations"

			{  [ "$OPTARG" -lt 1 ] 					\
			|| [ "$OPTARG" -gt "$MAX_CORES" ]; 			\
			} && error "Too many cores: $OPTARG"

			CRS="$OPTARG"
			;;
		p)
			command -v powertop > /dev/null 			\
				|| error "You need powertop."
			
			[ -n "$PWRTOP" ] && error "Too many powertop opt"

			{  [ "$OPTARG" = "nousb" ]				\
			|| [ "$OPTARG" = "full" ];				\
			} && PWRTOP="$OPTARG"

			[ -z "$PWRTOP" ] && error "$OPTARG not accepted."
			;;
		*)
			usage
			error "Unknown argument: -$opt"
			;;
	esac
done

# Print out the driver
DRIVER=$( cpufreqctl --driver )
printf "Using '$DRIVER' driver\\n"

# Get choices if not already defined
[ -z "$GOV" ] && { choose_governor || error "Failed to get governor"; }
[ -z "$FRQ" ] && { choose_frequency || error "Failed to get frequency"; }
[ -z "$CRS" ] && { choose_cores || error "Failed to get cores"; }

# Get confirmation
[ -z "$YES" ] && { confirm "$GOV" "$FRQ" "$CRS" || error "Abort."; }


printf "Applying changes...\\n"
# Governor and frequency
sudo cpufreqctl --governor --set="$GOV" > /dev/null 2>&1			\
	|| error "Failed to set governor"
sudo cpufreqctl --frequency-max --set="$FRQ" > /dev/null 2>&1			\
	|| error "Failed to set frequency"

# Manage cores
MAX_CORES=$(( MAX_CORES-1 ))
for i in $( seq "$CRS" "$MAX_CORES" ); do 
	sudo cpufreqctl --off --core="$i" || error "Error turning off core $i"
done
CRS=$(( CRS-1 ))
for i in $( seq 1 "$CRS" ); do 
	sudo cpufreqctl --on --core="$i" || error "Error turning on core $i"
done

# Powertop
[ -n "$PWRTOP" ] && enable_powertop "$PWRTOP" > /dev/null 2>&1 			\
	|| error "Error in powertop" 
