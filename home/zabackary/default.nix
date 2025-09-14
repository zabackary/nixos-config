{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ../common
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    ./flatpak.nix
    ./development.nix
  ];

  home.username = "zabackary";

  # MARK: User configuration

  # Flatpaks
  # Flatpaks are in flatpak.nix
  services.flatpak.update.auto.enable = false;
  services.flatpak.uninstallUnmanaged = true;

  home.packages = with pkgs; [
    kdePackages.plasma-browser-integration

    # GUI editors
    gimp3-with-plugins
    inkscape-with-extensions
    openshot-qt

    # GUI system utilities
    alacritty
    parted
    gnome-disk-utility
    remmina

    # Spell checking
    hunspell
    hunspellDicts.en_US
  ];

  # MARK: GUI applications
  programs.alacritty = {
    enable = true;
    settings = {
      blur = true;
      resize_increments = true;
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
  };
}
