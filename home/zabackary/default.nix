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
    # Browsers and browser utilities
    inputs.browser-previews.packages.${pkgs.stdenv.hostPlatform.system}.google-chrome # stable
    inputs.browser-previews.packages.${pkgs.stdenv.hostPlatform.system}.google-chrome-beta
    kdePackages.plasma-browser-integration

    # utils for x86_64
    sysstat
    lm_sensors # for `sensors` command
    ethtool

    # GUI editors
    gimp3-with-plugins
    inkscape-with-extensions
    # openshot-qt # openshot-qt depends on qtwebengine, which is currently marked as insecure. Therefore, it doesn't have CI builds and I can't build one myself.
    (
      let
        data = import ../../data/vscode.nix;
      in
      (vscode.overrideAttrs (oldAttrs: {
        src = builtins.fetchTarball {
          url = "https://update.code.visualstudio.com/${data.version}/linux-x64/stable";
          sha256 = data.sha256;
        };
        version = data.version;
        buildInputs =
          oldAttrs.buildInputs
          ++ (with pkgs; [
            curl
            webkitgtk_4_1
            libsoup_3
          ]);
      })).fhs
    )

    # GUI system utilities
    alacritty
    parted
    gnome-disk-utility
    remmina
    anki-bin
    inputs.rustdesk.packages.x86_64-linux.rustdesk

    # Spell checking
    hunspell
    hunspellDicts.en_US

    # Development
    corepack_24
    nodejs_24
    deno
    # inputs.cargo-v5.packages.${pkgs.stdenv.hostPlatform.system}.cargo-v5-full
  ];

  # MARK: GUI applications
  programs.alacritty = {
    enable = true;
    settings = {
      blur = true;
      resize_increments = true;
    };
  };
}
