#!/bin/bash
# For debug purpose :
#set -x

if [ "${currentscript:0:1}" == "-" ]; then
  scriptdir=$(realpath $(dirname "${BASH_SOURCE[0]}"))
else
  scriptdir=$(realpath $(dirname "$0"))
fi
. $scriptdir/.env

# Colors ======================================================================
# Reset
RESET='\033[0m'       # Text Reset

# Regular Colors
BLACK='\033[0;30m'        # Black
RED='\033[0;31m'          # Red
GREEN='\033[0;32m'        # Green
YELLOW='\033[0;33m'       # Yellow
BLUE='\033[0;34m'         # Blue
PURPLE='\033[0;35m'       # Purple
CYAN='\033[0;36m'         # Cyan
WHITE='\033[0;37m'        # White

# Bold
BBLACK='\033[1;30m'       # Black
BRED='\033[1;31m'         # Red
BGREEN='\033[1;32m'       # Green
BYELLOW='\033[1;33m'      # Yellow
BBLUE='\033[1;34m'        # Blue
BPURPLE='\033[1;35m'      # Purple
BCYAN='\033[1;36m'        # Cyan
BWHITE='\033[1;37m'       # White

# Underline
UBLACK='\033[4;30m'       # Black
URED='\033[4;31m'         # Red
UGREEN='\033[4;32m'       # Green
UYELLOW='\033[4;33m'      # Yellow
UBLUE='\033[4;34m'        # Blue
UPURPLE='\033[4;35m'      # Purple
UCYAN='\033[4;36m'        # Cyan
UWHITE='\033[4;37m'       # White

# Background
ON_BLACK='\033[40m'       # Black
ON_RED='\033[41m'         # Red
ON_GREEN='\033[42m'       # Green
ON_YELLOW='\033[43m'      # Yellow
ON_BLUE='\033[44m'        # Blue
ON_PURPLE='\033[45m'      # Purple
ON_CYAN='\033[46m'        # Cyan
ON_WHITE='\033[47m'       # White

# High Intensity
IBLACK='\033[0;90m'       # Black
IRED='\033[0;91m'         # Red
IGREEN='\033[0;92m'       # Green
IYELLOW='\033[0;93m'      # Yellow
IBLUE='\033[0;94m'        # Blue
IPURPLE='\033[0;95m'      # Purple
ICYAN='\033[0;96m'        # Cyan
IWHITE='\033[0;97m'       # White

# Bold High Intensity
BIBLACK='\033[1;90m'      # Black
BIRED='\033[1;91m'        # Red
BIGREEN='\033[1;92m'      # Green
BIYELLOW='\033[1;93m'     # Yellow
BIBLUE='\033[1;94m'       # Blue
BIPURPLE='\033[1;95m'     # Purple
BICYAN='\033[1;96m'       # Cyan
BIWHITE='\033[1;97m'      # White

# High Intensity backgrounds
ON_IBLACK='\033[0;100m'   # Black
ON_IRED='\033[0;101m'     # Red
ON_IGREEN='\033[0;102m'   # Green
ON_IYELLOW='\033[0;103m'  # Yellow
ON_IBLUE='\033[0;104m'    # Blue
ON_IPURPLE='\033[0;105m'  # Purple
ON_ICYAN='\033[0;106m'    # Cyan
ON_IWHITE='\033[0;107m'   # White

# Logging =====================================================================
function log () {
  test -n "$loglevel" || {
    loglevel=info;
  }


  current_loglevel=0
  case $loglevel in
    debug)
      current_loglevel=4;;
    info)
      current_loglevel=3;;
    warning)
      current_loglevel=2;;
    error)
      current_loglevel=1;;
    none)
      current_loglevel=0;;
    *)
      current_loglevel=1;;
  esac;

  current_loglevelprint=$current_loglevel;
  case $loglevelprint in
    debug)
      current_loglevelprint=4;;
    info)
      current_loglevelprint=3;;
    warning)
      current_loglevelprint=2;;
    error)
      current_loglevelprint=1;;
    none)
      current_loglevelprint=0;;
  esac;

  target_loglevel=0;
  case $1 in
    "debug")
      target_logleveltext="DEBUG";
      target_logleveltextprint="${PURPLE}DEBUG$RESET";
      target_loglevel=4;
      shift;;
    "info")
      target_logleveltext="INFO";
      target_logleveltextprint="INFO";
      target_loglevel=3;
      shift;;
    "warning")
      target_logleveltext="WARN";
      target_logleveltextprint="WARN";
      target_loglevel=2;
      shift;;
    "error")
      target_logleveltext="ERROR";
      target_logleveltextprint="${BRED}ERROR$RESET";
      target_loglevel=1;
      shift;;
    *)
      target_logleveltext="DEBUG";
      target_logleveltextprint="${PURPLE}DEBUG$RESET";
      target_loglevel=1;;
  esac

  timestamp=$(date +"%d%b%Y:%H:%M:%S %z")
  hostname=$(hostname)
  user=$(whoami)
  logline=""
  for item in $@ ;do
    logline="$logline $item"
  done
  logline="$@"
  if [ "$target_loglevel" -le "$current_loglevelprint" ]; then
    printf "$target_logleveltextprint: %s\n" "$logline"
  fi
  if [ "$target_loglevel" -le "$current_loglevel" ]; then
    mkdir -p $(dirname $logfile)
    printf "%s %s [%s] $target_logleveltext: %s\n" "$hostname" "$user" "$timestamp" "$logline" >> $logfile
  fi



}


function download {
  url=$1
  destination=$2
  if command -v curl >/dev/null 2>&1; then
    (cd $destination; curl -sLO $url)
  elif command -v wget >/dev/null 2>&1; then
    (cd $destination; wget -q $url)
  fi
}

