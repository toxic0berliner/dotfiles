#!/bin/bash

scriptdir="$(realpath $(dirname $0))"
cd $scriptdir

if [ ! -f .env ] || [ ! -f common.sh ]; then
  echo "ERROR: need .env and common.sh scripts. Exiting."
  exit 1
fi

. .env
. common.sh

log info "Generating list of files to be downloaded for installation without git."

outputfile="$scriptdir/downloads.txt"

log debug "Writing to $outputfile"

if [ -f $outputfile ]; then 
  rm $outputfile
fi

function addfile () {
  echo $1 >> $outputfile
}

function addpackage() {
cd $scriptdir
cd $1
log debug "Adding Package $1"
for d in $(find . -type d); do
  for f in $(find $d -maxdepth 1 -type f); do
    ff="${f:2}"
    addfile $1/$ff
    log debug "Found $ff in $d, added to the list."
  done
done
}

addfile ".env"
addfile "common.sh"
addfile "install.sh"
addfile "install-binaries.sh"
addpackage "bin"
addpackage "home"

log info "Done generating the list of files to be downlaoded for installation without git."
