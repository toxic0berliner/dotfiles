#!/bin/bash

scriptdir=$(realpath $(dirname $0))
. $scriptdir/common.sh

log info "Installing dotfiles..."

mkdir -p $dotfiles

# Install stowaway https://github.com/jamesbehr/stowaway
if [ ! -f $dotfiles/bin/stowaway ]; then
  log debug "Downloading stowaway..."
  download  https://github.com/jamesbehr/stowaway/releases/latest/download/stowaway-linux-amd64.tar.gz $dotfiles/bin/
  download  https://github.com/jamesbehr/stowaway/releases/latest/download/stowaway-linux-amd64.tar.gz.sha256sum $dotfiles/bin/
  log debug "  Verifying checksum..."
  d=$(cd $dotfiles/bin; sha256sum -c stowaway-linux-amd64.tar.gz.sha256sum)
  log debug "sha256 check: $d"
  if [ "$(echo $d | grep OK | wc -l)" -le 0 ]; then
    log debug "    Last command: $?"
    log error "  Unable to download stowaway."
  else
    log info "Installing stowaway..."
    tar -xzf $dotfiles/bin/stowaway-linux-amd64.tar.gz -C $dotfiles/bin/ >/dev/null 2>&1
    rm $dotfiles/bin/stowaway-linux-amd64.tar.gz $dotfiles/bin/stowaway-linux-amd64.tar.gz.sha256sum
    chmod +x $dotfiles/bin/stowaway
  fi
else
  log debug "Stoaway already installed, continuing."
fi

#Backing up existing files
log info "Backing up existing files..."
cd $dotfiles/home
suffix=$(date +"%Y-%m-%d_%Hh%Mm%Ss")
for d in $(find . -type d); do
  for f in $(find $d -maxdepth 1 -type f); do
    ff="${f:2}"
    if [ -f $HOME/$f ]; then
      backupfile="origin.bak/${ff//\//-}.$suffix"
      log info "    backing up $(basename $f) from $HOME to $backupfile"
      cp $HOME/$f $dotfiles/$backupfile
      if [ "$?" -ne 0 ]; then
        log error "        Unable to backup $(basename $f) ($f) from $HOME to $dotfiles/$backupfile"
      else
        rm $HOME/$f
      fi
    else
      log debug "    no prior $ff found in $HOME/${d:2}"
    fi
  done
done

log info "Running stowaway..."
cd $dotfiles
./bin/stowaway stow home --target $HOME

if command -v git >/dev/null 2>&1; then
  log info "Setting up tmux.."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

log info "Installing binaries"
./install-binaries.sh

log info "dotfiles install completed."
