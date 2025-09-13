#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

if [ -z "$(git status --porcelain)" ]; then
  echo "Switching NixOS configuration..."
  nixos-rebuild switch --flake .# --use-remote-sudo
  echo "NixOS configuration switched successfully. Remember to `git push` your changes."
else 
  echo "There are uncommitted changes in the repository. Please commit or stash them before switching configurations."
  exit 1
fi

