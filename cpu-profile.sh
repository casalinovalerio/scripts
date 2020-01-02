#!/usr/bin/env sh

error() { printf "E: $1\\n"; exit 1; }

command -v cpufreqctl || error "Install cpufreqctl"
driver=$( cpufreqctl --driver )
printf "Using '$driver' driver\\n"

printf "Choose governor...\\n"
govChoice=$( printf "conservative\\nperformance\\nschedutil\\nondemand" | dmenu ) || exit

printf "Choose frequency...\\n"
freqChoice=$( printf "$(cpufreqctl --frequency --available | tr ' ' '\n')" | dmenu ) || exit

nCpu=$(find /sys/devices/system/cpu/ -maxdepth 1 -name "*cpu[0-9]*" -type d | wc -l)
printf "How many cores you want to disable? [max=$nCpu -1]\\n"
let nCpu=nCpu-1
nDis=$( for n in $( seq 0 $nCpu ); do printf "$n\\n"; done | dmenu ) || exit

printf "Governor choice: $govChoice\\n"
printf "Frequency choice: $freqChoice\\n"
printf "Cores to disable: $nDis\\n"
printf "Is it correct? [yY/nN]: "
read yn
[ $yn != 'y' ] && [ $yn != 'Y' ] && error "Abort."

printf "Applying changes...\\n"
let nDis=nCpu-nDis
let nDis=nDis+1

sudo cpufreqctl --governor --set=$govChoice
sudo cpufreqctl --frequency-max --set=$freqChoice
for i in $( seq $nDis $nCpu | tac ); do sudo cpufreqctl --off --core=$i; done

printf "All done!\\nGovernor status:\\n"
cpufreqctl  --governor | tr ' ' '\n' | nl | sed "s/^     /Core#/g" | tr '\t' '-'

printf "Frequency report:\\n"
for i in $( seq 0 $nCpu ); do printf "Core#$i: "; cpufreqctl --frequency --core=$i; done
