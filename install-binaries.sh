#!/bin/bash

scriptdir=$(realpath $(dirname $0))
. $scriptdir/common.sh

log info "Installing packages..."

# Check if we can install packages
sudoavailable=false
if command -v sudo >/dev/null 2>&1; then
    sudoavailable=true
fi
if [ "$sudoavailable" == "true" ]; then 
  id=$(SUDO_ASKPASS=/bin/false sudo -A id 2>&1 )
  if [ "${id:0:5}" == "uid=0" ]; then
      can_sudo=true
  else
      log debug "Unexpected sudo response: $id"
      can_sudo=false
  fi
else # sudo is not available
  can_sudo=false
fi

id=$(id)
if [ "$(whoami)" == "root" ] || [ ${id:0:5} == "uid=0" ]; then 
  is_root=true
else
  is_root=false
fi

log debug "can_sudo=$can_sudo and is_root=$is_root"
if [ "$can_sudo" = "true" ] || [ "$is_root" = true ]; then
  log info "Installing needed packages..."
  pkginstall tmux 
  pkginstall git 
  pkginstall vim
  pkginstall tree
  #pkginstall bat 
  #pkginstall zoxide 
  #pkginstall fzf 
  #pkginstall dust
  pkginstall btop 
  #pkginstall delta 
  #pkginstall eza
  log info "Installed all needed packages."
fi


log info "Attempting install of binaries without package manager."

usrbin="$HOME/.local/bin"
if [ ! -d "$usrbin" ]; then
  mkdir -p "$usrbin"
fi

cmd="tmux"
if ! command -v $cmd >/dev/null 2>&1; then
  log info "Installing $cmd."
  download "https://github.com/toxic0berliner/dotfiles/raw/master/bin/tmux" "$usrbin"
fi

cd $usrbin

cmd="eget"
if ! command -v $cmd >/dev/null 2>&1; then
  log info "Installing $cmd."
  if [ ! "$(command -v curl >/dev/null 2>&1)" ]; then
    curl "https://zyedidia.github.io/eget.sh" | sh
  elif [ ! "$(command -v wget >/dev/null 2>&1)" ]; then
    wget "https://zyedidia.github.io/eget.sh" -O - | sh
  else
    log error "Both curl and wget are unavailable. Exiting."
    exit 1;
  fi
fi

cmd="zoxide"
if ! command -v $cmd >/dev/null 2>&1; then
  log info "Installing $cmd."
  ./eget "ajeetdsouza/zoxide"
fi

cmd="fzf"
if ! command -v $cmd >/dev/null 2>&1; then
  log info "Installing $cmd."
  ./eget "junegunn/fzf"
fi

cmd="bat"
if ! command -v $cmd >/dev/null 2>&1; then
  log info "Installing $cmd."
  ./eget "sharkdp/bat" --asset musl
fi

cmd="eza"
if ! command -v $cmd >/dev/null 2>&1; then
  log info "Installing $cmd."
  ./eget "eza-community/eza" --tag "v0.18.17" --asset musl --asset tar
fi

cmd="fd"
if ! command -v $cmd >/dev/null 2>&1; then
  log info "Installing $cmd."
  ./eget "sharkdp/fd"  --asset musl --asset tar
fi

cmd="sd"
if ! command -v $cmd >/dev/null 2>&1; then
  log info "Installing $cmd."
  ./eget "chmln/sd"  --asset musl --asset tar
fi

cmd="dua"
if ! command -v $cmd >/dev/null 2>&1; then
  log info "Installing $cmd."
  ./eget "Byron/dua-cli"  --asset musl --asset tar
fi

cmd="delta"
if ! command -v $cmd >/dev/null 2>&1; then
  log info "Installing $cmd."
  ./eget "dandavison/delta"  --asset musl --asset tar
fi

cmd="difftastic"
if ! command -v $cmd >/dev/null 2>&1; then
  log info "Installing $cmd."
  ./eget "Wilfred/difftastic"  --asset tar
fi

cmd="lazygit"
if ! command -v $cmd >/dev/null 2>&1; then
  log info "Installing $cmd."
  ./eget "jesseduffield/lazygit"  --asset tar
fi

cmd="starship"
if ! command -v $cmd >/dev/null 2>&1; then
  log info "Installing $cmd."
  ./eget "starship/starship"  --asset musl --asset tar
fi

chmod -R +x $usrbin
