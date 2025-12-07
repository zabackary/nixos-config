#!/usr/bin/env bash

ALLOW_DIRTY=0

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --allow-dirty) ALLOW_DIRTY=1 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 
  exit 1
fi

if [ -z "$(git status --porcelain)" ] || [[ $ALLOW_DIRTY -eq 1 ]]; then
  echo "Switching NixOS configuration..."
  nixos-rebuild switch --flake .# --sudo
  if [[ $? -eq 0 ]]; then
   echo "NixOS configuration switched successfully. Remember to \`git push\` your changes."
  else
   exit 1
  fi
else 
  echo "There are uncommitted changes in the repository. Please commit or stash them before switching configurations."
  exit 1
fi
