---
layout: default
---

## My work-flow helpers

### cpu-profile.sh

**[cpu-profile.sh](https://github.com/casalinovalerio/scripts/raw/actual-scripts/cpu-profile.sh)** is a script that tweaks your system to make it consume less power :zap:. It relies on `powertop` and `cpufreqctl` to set a [CPU scaling governor](https://wiki.archlinux.org/index.php/CPU_frequency_scaling#Scaling_governors), a maximum frequency for your cores and the number of cores you want to use. If arguments are not passed to the script, it will prompt you to insert them. Your battery will be grateful :battery:.

![cpu-profile.gif](/assets/gifs/cpu-profile.gif)

### crypt.sh

**[crypr.sh](https://github.com/casalinovalerio/scripts/raw/actual-scripts/crypt.sh)** is a small utility, wrapper for `openssl`, that you can use to encrypt :lock: and decrypt :key: your files.

![crypt.gif](/assets/gifs/crypt.gif)

### tinyurl.sh

**[tinyurl.sh](https://github.com/casalinovalerio/scripts/raw/actual-scripts/tinyurl.sh)** is a small script that makes your URLs :link: shorter by using [Tinyurl](https://tinyurl.com)’s API.

![tinyurl.gif](/assets/gifs/tinyurl.gif)

### gitio.sh

**[gitio.sh](https://github.com/casalinovalerio/scripts/raw/actual-scripts/gitio.sh)** is a small script that makes your Github URLs :octocat: :link: shorter by using Github’s [git.io](https://git.io) service.

![gitio.gif](/assets/gifs/gitio.gif)

### round-image-cropper.sh

**[round-image-cropper.sh](https://github.com/casalinovalerio/scripts/blob/actual-scripts/round-image-cropper.sh)** is pretty self explanatory… :scissors: :scissors:

![round-image-cropper.webp](/assets/images/round-image-cropper.webp)

### optimize-boot.sh

**[optimize-boot.sh](https://github.com/casalinovalerio/scripts/blob/actual-scripts/optimize-boot.sh)** is a simple utility that increases boot time :hourglass_flowing_sand:. It is not completed yet, but I’m working on it. In the gif below there are the benefits for my system.

![optimize-boot.gif](/assets/gifs/optimize-boot.gif)

### pdf-compress.sh

**[pdf-compress.sh](https://github.com/casalinovalerio/scripts/blob/actual-scripts/pdf-compress.sh)** is a simple Ghostscript wrapper to compress a pdf offline. Works pretty fine :sunglasses: :page_facing_up:. 

![round-image-cropper.webp](/assets/images/pdf-compress.webp)

### wallpaper-download.sh

**[wallpaper-download.sh](https://github.com/casalinovalerio/scripts/blob/actual-scripts/wallpaper-download.sh)** is a script that gets the [Nasa's APOD](https://apod.nasa.gov/apod/astropix.html) :earth_americas: and the [BING's daily wallpaper](https://www.bing.com/) :mag: putting them in the `~/Pictures` folder.

### youtube-download.sh

**[youtube-download.sh](https://github.com/casalinovalerio/scripts/blob/actual-scripts/youtube-download.sh)** is a mini-wrapper to download the best possible format of a yt video with metadata and basic stuff.
