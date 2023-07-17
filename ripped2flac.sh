#!/bin/bash
#
# rippedtoflack.sh; part of jacktheripper - automated cd ripper
#
# This script picks up jacktheripper.log if there are new cd's ripped by
# jacktheripper.sh and converts them to FLAC.
#
# Author: Michel Hoogervorst <michel@highking.nl>
#

[ -f /home/public/jacktheripper.log ] || exit 1
[ -f /home/public/jacktheripper.log.1 ] && exit 1
mv /home/public/jacktheripper.log /home/public/jacktheripper.log.1
for id in $(</home/public/jacktheripper.log.1); do  
  # Try to open the directory with this id
  cd /home/public/rip$id || exit 1

  # Get album information
  albumartist=$(grep Albumperformer audio_01.inf | cut -d"'" -f2- | sed "s/'$//g")
  album=$(grep Albumtitle audio_01.inf | cut -d"'" -f2- | sed "s/'$//g")
  albumdir=$(echo "$album" | sed "s/\//_/g")
  year=$(grep DYEAR audio.cddb | cut -d'=' -f2)
  genres=$(grep DGENRE audio.cddb | cut -d'=' -f2)

  # Create the directory for this album
  mkdir -p "$albumartist/$albumdir" || exit 1

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
    flac -8 $track -o "$albumartist/$albumdir/$tracknumber - $title.flac" || exit 1

    # Add metadata to the file
    metaflac --set-tag=ARTIST="$artist" "$albumartist/$albumdir/$tracknumber - $title.flac"
    metaflac --set-tag=ALBUM="$album" "$albumartist/$albumdir/$tracknumber - $title.flac"
    metaflac --set-tag=TITLE="$title" "$albumartist/$albumdir/$tracknumber - $title.flac"
    metaflac --set-tag=TRACKNUMBER="$tracknumber" "$albumartist/$albumdir/$tracknumber - $title.flac"
    [ -z ${year+x}  ] || metaflac --set-tag=DATE="$year" "$albumartist/$albumdir/$tracknumber - $title.flac"

    # Add genre tag(s), can be space delimited
    if [ ! -z ${genres+x} ]; then
      IFS=";"
      for genre in ${genres// / }; do
          metaflac --set-tag=GENRE="$genre" "$albumartist/$albumdir/$tracknumber - $title.flac"
      done
    fi

  done

  # Add ReplayGain tags to the files (this has to be done for the whole album at once)
  pushd "$albumartist/$albumdir"
  metaflac --add-replay-gain *flac
  popd

  # Copy cover file, if it exists
  for coverart in cover.jpg cover.png; do
    if [ -f $coverart ]; then
      cp $coverart "$albumartist/$albumdir/"
    fi
  done

  # Move converted files to our music collection
  if [ -d "/home/public/Muziek/$albumartist" ]; then
    mv "$albumartist/$albumdir" "/home/public/Muziek/$albumartist/$albumdir"
  else
    mv "$albumartist" "/home/public/Muziek/$albumartist"
  fi

  # Remove original rip
  #if [ "$?" == "0" ]; then
  #  cd ~
  #  rm -rf /home/public/rip$id
  #fi

done && rm -f /home/public/jacktheripper.log.1
