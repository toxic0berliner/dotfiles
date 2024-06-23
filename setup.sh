#!/bin/bash

installroot=$HOME
installfolder=".dotfiles"
giturlssh="ssh://git@gitlab.amato.top:8022/toxic/dotfiles.git"
giturlhttps="https://gitlab.amato.top/toxic/dotfiles.git"
downloadurlbase="https://gitlab.amato.top/toxic/dotfiles/-/raw/master"
downloadurlsuffix="?ref_type=heads&inline=false"


mirrorfallback_timeout=5
giturlssh_mirror="ssh://git@github.com:toxic0berliner/dotfiles.git"
giturlhttps_mirror="https://github.com/toxic0berliner/dotfiles.git"
downloadurlbase_mirror="https://raw.githubusercontent.com/toxic0berliner/dotfiles/master/"
downloadurlsuffix_mirror=""


#@todo: fallback to github in case amato.top is unavailable.

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
  elif command -v wget >/dev/null 2>&1; then
    (cd $destination; wget -q $url)
  fi
}

function _select_mirror {
  choosemirror=false
  if command -v curl >/dev/null 2>&1; then
    curl -sL --connect-timeout $mirrorfallback_timeout "$downloadurlbase" > /dev/null 2>&1
    if [ "$?" -ne "0" ]; then
	choosemirror=true;
	#echo "curl unable to connect to $downloadurlbase in less than $mirrorfallback_timeout"
    fi;
  elif command -v wget >/dev/null 2>&1; then
    wget -q --timeout $mirrorfallback_timeout "$downloadurlbase" > /dev/null 2>&1
    if [ "$?" -ne "0" ]; then
	choosemirror=true;
	#echo "wget unable to connect to $downloadurlbase in less than $mirrorfallback_timeout"
    fi;
  fi
  if [ "$choosemirror" == "true" ]; then
    echo "Falling back to mirror."
    downloadurlbase=$downloadurlbase_mirror
    downloadurlsuffix=$downloadurlsuffix_mirror
    giturlssh=$giturlssh_mirror
    giturlhttps=$giturlhttps_mirror
  fi
}

if [ -d $fullinstallfolder ]; then 
  if [ -f "$fullinstallfolder/common.sh" ]; then
    . $fullinstallfolder/common.sh
    log warning "Not re-fetching $installfolder as it already exists ($fullinstallfolder)"
  else
    echo "Not re-fetching $installfolder as it already exists ($fullinstallfolder)"
  fi
else
  _select_mirror
  if $gitavailable; then # fetch using git ======================================
    mkdir -p $installroot
    cd $installroot
  
    #@todo: fallback to https if unable to establish ssh connection.
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
    chmod +x ./*.sh ./.env ./bin/*
    mkdir -p $fullinstallfolder/log $fullinstallfolder/origin.bak
  fi
fi

cd $installroot
$fullinstallfolder/install.sh
