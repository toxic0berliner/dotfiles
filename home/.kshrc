# .kshrc

# Source global definitions
if [ -f /etc/kshrc ]; then
        . /etc/kshrc
fi

# use emacs editing mode by default
set -o emacs

# User specific aliases and functions
if [[ $- = *i* ]]; then
    if [ -z "$KSHRC_SOURCED" ]; then
      export KSHRC_SOURCED=true;
    fi
    bash
    exit
fi
