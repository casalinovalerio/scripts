---
layout: default
---

**[cpu-profile.sh](https://github.com/casalinovalerio/scripts/raw/actual-scripts/cpu-profile.sh)** is a script that tweaks your system to make it consume less power. It relies on `powertop` and `cpufreqctl` to set a [CPU scaling governor](https://wiki.archlinux.org/index.php/CPU_frequency_scaling#Scaling_governors), a maximum frequency for your cores and the number of cores you want to use. If arguments are not passed to the script, it will prompt you to insert them.

![cpu-profile.gif](/assets/gifs/cpu-profile.gif)

