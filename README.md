# Jack the Ripper

This is a set of scripts providing automatically ripping an audio CD
and converting it to flac. The ripping and converting is done in seperate 
scripts simply because my raspberry-pi with KODI was not up to the 
FLAC converting task back in 2016 when I wrote this. So the converting
script has been running on a seperate machine since.

Files:
* 999-jacktheripper.rules  : UDEV rules running jacktheripper.sh when an audio-cd is inserted
* jacktheripper.sh         : The cd-ripping script
* ripped2flac.sh           : The FLAC conversion script.
* README.md                : This README file. ;-)

This was written for personal use. Feel free to use whatever you need from it.
