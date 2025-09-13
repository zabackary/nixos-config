#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

if [ -z "$(git status --porcelain)" ]; then 
  # nixos-rebuild switch --flake .# --use-remote-sudo
  echo clean
else 
  echo Uncommitted changes
fi

