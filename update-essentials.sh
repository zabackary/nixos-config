#! /usr/bin/env nix-shell
#!nix-shell -i bash -p nix git jq

set -eou pipefail

# MARK: Chrome
# Update Chrome by updating browser-previews flake
nix flake update browser-previews

# MARK: VSCode
# Update VSCode by updating data/vscode.nix
# Inspired by https://github.com/NixOS/nixpkgs/blob/85ac135c532ef5afe8c067f07c5b0e87873bdd62/pkgs/applications/editors/vscode/update-vscode.sh
latestVersion=$(curl --fail --silent https://code.visualstudio.com/sha?build=stable | jq --raw-output .products.[0].name)
currentVersion=$(nix eval --raw -f data/vscode.nix version)

echo "latest  version: $latestVersion"
echo "current version: $currentVersion"

if [[ "$latestVersion" == "$currentVersion" ]]; then
  echo "package is up-to-date"
else
  echo "updating package to $latestVersion"
  latestSha256=$(nix hash convert --to sri --hash-algo sha256 $(nix-prefetch-url --unpack "https://update.code.visualstudio.com/$latestVersion/linux-x64/stable"))

  sed -i \
    -e "s/  version = \".*\";/  version = \"$latestVersion\";/" \
    -e "s|  sha256 = \".*\";|  sha256 = \"$latestSha256\";|" \
    data/vscode.nix

  echo "updated data/vscode.nix"
fi
