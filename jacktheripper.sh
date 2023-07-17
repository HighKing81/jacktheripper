#!/bin/bash
#
# jacktheripper.sh; automatically rip an inserted audio cd.
#
# Author: Michel Hoogervorst <michel@highking.nl>
# Date: 29 oktober 2016

# Do not run twice...
ps aux | grep -v $$ | grep -q jacktherippe[r] && exit 1

# Don't run if no argument is given. The udev rule will provide this.
if [ "$1" == "" ]; then
  echo "Please provide a device-name"
  exit 1
fi

# I need to schedule myself through 'at' because of udevs' timeout
if [ "$2" != GO ]; then
  echo $0 $1 GO | at now
  exit 0
fi

# mount a server share to write on and open it
if ! grep -q jacktheripper /proc/mounts; then
  mount -t cifs -o username=*CIFSUSER*,password=*CIFSPASSWORD* //server.address/public /mnt/jacktheripper || exit 1
fi

# Open the server share
cd /mnt/jacktheripper || exit 1

# Create a temporary directory for ripping the inserted disc
mkdir rip$$
cd rip$$ || exit 1

# rip the disc's contents and fetch cddb-info
icedax -L 0 -B -D $1 && eject $1

# Write to logfile which can be picked-up by the flac conversion-script
echo $$ >> /mnt/jacktheripper/jacktheripper.log
