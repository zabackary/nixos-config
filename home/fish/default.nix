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
