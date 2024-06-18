#!/bin/bash

scriptdir=$(realpath $(dirname $0))
. $scriptdir/common.sh

log info "Refreshing dotfiles..."

#Backing up existing files
log info "Backing up existing files..."
cd $dotfiles/home
suffix=$(date +"%Y-%m-%d_%Hh%Mm%Ss")
for d in $(find . -type d); do
  for f in $(find $d -maxdepth 1 -type f); do
    ff="${f:2}"
    if [ -f $HOME/$f ] && [ ! -L $HOME/$f ]; then
      backupfile="origin.bak/${ff//\//-}.$suffix"
      log info "    backing up $(basename $f) from $HOME to $backupfile"
      cp $HOME/$f $dotfiles/$backupfile
      if [ "$?" -ne 0 ]; then
        log error "        Unable to backup $(basename $f) ($f) from $HOME to $dotfiles/$backupfile"
      else
        rm $HOME/$f
      fi
    elif [ -L $HOME/$f ]; then
      log debug "    already linked $ff found in $HOME/${d:2}"
    else
      log debug "    no prior $ff found in $HOME/${d:2}"
    fi
  done
done

log info "Running stowaway..."
cd $dotfiles
./bin/stowaway stow home --target $HOME

log info "dotfiles refresh completed."
