# Jack the Ripper

This is a set of scripts providing automatically ripping of an audio CD
and converting it to flac. The ripping and converting is done in seperate 
scripts simply because my raspberry-pi with KODI was not up to the 
FLAC converting task back in 2016 when I wrote this. So the converting
script has been running on a seperate machine since.

##Files:
* 999-jacktheripper.rules  : UDEV rules running jacktheripper.sh when an audio-cd is inserted
* jacktheripper.sh         : The cd-ripping script
* ripped2flac.sh           : The FLAC conversion script.
* README.md                : This README file. ;-)

This was written for personal use. Feel free to use whatever you need from it.

##Usage:
  Put 999-jacktheripper.rules in your udev.d directory so udev will start jacktheripper.sh
  as soon as you insert a CD with audio tracks on it.

  Put jacktheripper.sh in /usr/local/bin and make sure it's executable. This will handle
  the ripping. It needs icedax, which will do the actual ripping. It also needs the 'at'
  command to reschedule itself. This is a workaround against the time limit of UDEV.
  On my machine it mounts a samba share on /mnt/jacktheripper so make sure to change 
  the *CIFSUSER* and *CIFSPASSWORD* to your own if you plan to do the same, 
  or delete the mount stuff and change the location... ;-) 

  The ripped2flac.sh you can place on the machine which will do the converting from
  wav to flac. This expects a file /home/public/jacktheripper.log which is created 
  by jacktheripper.sh and directories called 'ripxxx' where xxx is a (not so) random
  number in which the rips reside.
  After converting, it will try to move the music to /home/public/Music (again, feel free
  to change for your environment).
  This script needs flac, metaflac, cut and sed to do it's "magic".

  The ripped2flac script will read it's info from audio_xx.inf files from a rip. You might
  want to make sure these are actually filled in. Also, if there's a cover.jpg file in the 
  same directory as the rip, it will copy that into the destination directory.

  After all is done, the file jacktheripper.log will be renamed to jacktheripper.log.1 to
  make sure it won't convert anything twice. You can uncomment the deletion of the original
  rip at the end of the script if you're as fearless as I am.


That's all folks!
 
