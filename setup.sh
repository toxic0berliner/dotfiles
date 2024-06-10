#!/bin/bash

installroot=$HOME
installfolder=".dotfiles"
giturlssh="ssh://git@gitlab.amato.top:8022/toxic/dotfiles.git"
giturlhttps="https://gitlab.amato.top/toxic/dotfiles.git"
#downloadurl="https://gitlab.amato.top/toxic/dotfiles/-/raw/master/README.md?ref_type=heads&inline=false"
downloadurlbase="https://gitlab.amato.top/toxic/dotfiles/-/raw/master"
downloadurlsuffix="?ref_type=heads&inline=false"

fullinstallfolder="$installroot/$installfolder"
gitavailable=false
if command -v git >/dev/null 2>&1; then
    gitavailable=true
fi

function download {
  url=$1
  destination=$2
  if command -v curl >/dev/null 2>&1; then
    (cd $destination; curl -sLO $url)
  elif command -v curl >/dev/null 2>&1; then
    (cd $destination; wget -q $url)
  fi
}

if $gitavailable; then # fetch using git ======================================
  mkdir -p $installroot
  cd $installroot
  git clone $giturlssh $installfolder
  if [ "$?" -ne 0 ]; then
    echo "retrying"
    git clone $giturlhttps $installfolder
  fi
else #git is not available, fetch manually ====================================
  mkdir -p $fullinstallfolder/
  download $downloadurlbase/downloads.txt$downloadurlsuffix $fullinstallfolder/

  cd $fullinstallfolder
  for f in $(cat $fullinstallfolder/downloads.txt); do
    echo "Downloading $f."
    d="."
    if [[ "$f" =~ "/" ]]; then
      d=$(dirname $f)
      mkdir -p $d 2>/dev/null
      cd $d
    fi
      download $downloadurlbase/$f$downloadurlsuffix $fullinstallfolder/$d/
    if [[ "$f" =~ "/" ]]; then
      cd $fullinstallfolder
    fi
  done

  cd $fullinstallfolder/
  chmod +x ./*.sh ./.env ./stowaway
  mkdir -p $fullinstallfolder/log $fullinstallfolder/origin.bak
fi

cd $installroot
$fullinstallfolder/install.sh
