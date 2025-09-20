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
  ];

  home = {
    username = "zabackary";

    sessionVariables = {
      XDG_DATA_DIRS = "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
    };
  };

  # MARK: User configuration

  # Flatpaks
  # Flatpaks are in flatpak.nix
  services.flatpak.update.auto.enable = false;
  services.flatpak.uninstallUnmanaged = true;

  home.packages = with pkgs; [
    kdePackages.plasma-browser-integration

    # utils for x86_64
    sysstat
    lm_sensors # for `sensors` command
    ethtool

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

    # Development
    corepack_24
    nodejs_24
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
