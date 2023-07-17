#!/bin/bash
#
# rippedtoflack.sh; part of jacktheripper - automated cd ripper
#
# This script picks up jacktheripper.log if there are new cd's ripped by
# jacktheripper.sh and converts them to FLAC.
#
# Author: Michel Hoogervorst <michel@highking.nl>
# Date: 9 december 2019 

[ -f /home/public/jacktheripper.log ] || exit 1
[ -f /home/public/jacktheripper.log.1 ] && exit 1
mv /home/public/jacktheripper.log /home/public/jacktheripper.log.1
for id in $(</home/public/jacktheripper.log.1); do  

  # Try to open the directory with this id
  cd /home/public/rip$id || exit 1

  # Get album information
  albumartist=$(grep Albumperformer audio_01.inf | cut -d"'" -f2- | sed "s/'$//g")
  album=$(grep Albumtitle audio_01.inf | cut -d"'" -f2- | sed "s/'$//g")
  year=$(grep DYEAR audio.cddb | cut -d'=' -f2)
  genre=$(grep DGENRE audio.cddb | cut -d'=' -f2)

  # Create the directory for this album
  mkdir -p "$albumartist/$album" || exit 1

  # Convert all .wav files to .flac
  for track in *wav; do
    # Get track-specific information
    infofile=${track%%wav*}inf
    artist=$(grep ^Performer $infofile | cut -d"'" -f2- | sed "s/'$//g")
    title=$(grep Tracktitle $infofile | cut -d"'" -f2- | sed "s/'$//g" | sed "s/[/.]//g")  # NO DOTS AND SLASHES PLEASE
    tracknumber=$(grep Tracknumber $infofile | awk '{print$2}')

    # prepend a zero if the tracknumber is <10
    if [ ${#tracknumber} == 1 ]; then
      tracknumber=0$tracknumber
    fi

    # Convert the .wav to .flac
    flac -8 $track -o "$albumartist/$album/$tracknumber - $title.flac" || exit 1

    # Add metadata to the file
    metaflac --set-tag=ARTIST="$artist" "$albumartist/$album/$tracknumber - $title.flac"
    metaflac --set-tag=ALBUM="$album" "$albumartist/$album/$tracknumber - $title.flac"
    metaflac --set-tag=TITLE="$title" "$albumartist/$album/$tracknumber - $title.flac"
    metaflac --set-tag=TRACKNUMBER="$tracknumber" "$albumartist/$album/$tracknumber - $title.flac"
    [ -z ${genre+x} ] || metaflac --set-tag=GENRE="$genre" "$albumartist/$album/$tracknumber - $title.flac"
    [ -z ${year+x}  ] || metaflac --set-tag=DATE="$year" "$albumartist/$album/$tracknumber - $title.flac"

  done

  # Add ReplayGain tags to the files (this has to be done for the whole album at once)
  pushd "$albumartist/$album"
  metaflac --add-replay-gain *flac
  popd

  # Move converted files to our music collection
  if [ -d "/home/public/Muziek/$albumartist" ]; then
    mv "$albumartist/$album" "/home/public/Muziek/$albumartist/$album"
  else
    mv "$albumartist" "/home/public/Muziek/$albumartist"
  fi

  # Remove original rip
  if [ "$?" == "0" ]; then
    cd ~
    rm -rf /home/public/rip$id
  fi

done && rm -f /home/public/jacktheripper.log.1
