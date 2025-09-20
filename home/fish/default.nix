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

  home.username = "fish"; # glub glub

  programs.home-manager.enable = true;

  nix = {
    package = pkgs.nix;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
