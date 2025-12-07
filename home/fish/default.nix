# User profile for fish@pond (Mac Mini M4 server)
{
  inputs,
  lib,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ../common
  ];

  # Allow unfree packages (since we aren't on NixOS where it's allowed globally)
  nixpkgs.config.allowUnfree = true;

  home = {
    username = "fish"; # glub glub
    homeDirectory = "/Users/fish";
  };

  programs.home-manager.enable = true;

  programs.vscode.enable = true; # mostly for the cli

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
