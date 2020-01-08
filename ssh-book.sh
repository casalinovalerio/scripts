#!/bin/bash
### Author: 	 Valerio Casalino
### Licence: 	 GPLv3
### Description: Connect with ssh to an host from ./lib/ssh_bookmarks

error() { printf "$1\\n"; exit 1; }

SCRIPT=$( readlink -f $0 )
SCRIPTPATH=$( dirname $SCRIPT )
BOOKMARKSPATH="$SCRIPTPATH/lib"
BOOKMARKS="$BOOKMARKSPATH/ssh_bookmarks"

# Create bookmarks file if it doesn't already exist
[ ! -d "$BOOKMARKSPATH" ] && mkdir "$BOOKMARKSPATH"
[ ! -f "$BOOKMARKS" ] && printf "# The syntax is simple \"hostname:user:ipv4\"\\n" > "$BOOKMARKS"

# Invite user to populate it following the syntax
[ $( wc -l < "$BOOKMARKS" ) -le 1 ] && error "No bookmarks in bookmark file ($BOOKMARKS)"

# Check if drun is installed
command -v dmenu > /dev/null || error "Pleas install dmenu"

# Actual choice and connection
choice=$( tail -n +2 "$BOOKMARKS" | cut -d ":" -f 1 | dmenu )
ipv4=$( grep "$choice" "$BOOKMARKS" | cut -d ":" -f 3 )
ssh_user=$( grep "$choice" "$BOOKMARKS" | cut -d ":" -f 2 )

ssh "$ssh_user@$ipv4"
