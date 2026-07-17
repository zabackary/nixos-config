{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ../common
    ../common/gui.nix
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    # inputs.noctalia.homeModules.default
    ./flatpak.nix
    ./systemd.nix
  ];

  home = {
    username = "zabackary";

    sessionVariables = {
      XDG_DATA_DIRS = "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
      NIXOS_OZONE_WL = "1"; # hint to Electron/chromium to use Wayland
      # XDG_CURRENT_DESKTOP = "KDE"; # pretend to be KDE, even on hyprland
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
        # VSCode moved the binary location around 1.122.0 and nixpkgs-26.05
        # doesn't have nixpkgs#525492 backported yet. I've hardcoded linux-x64 here
        # FIXME: Remove this when the backport is in place
        postPatch =
          lib.replaceStrings [ "@vscode/ripgrep/bin/rg" ] [ "@vscode/ripgrep-universal/bin/linux-x64/rg" ]
            oldAttrs.postPatch;

      })).fhs
    )
    (zed-editor.fhsWithPackages (
      pkgs: with pkgs; [
        nodejs_24
      ]
    ))

    # GUI system utilities
    parted
    gnome-disk-utility
    remmina
    anki-bin
    rustdesk-flutter
    keepassxc
    qalculate-qt
    rquickshare

    # Spell checking
    hunspell
    hunspellDicts.en_US

    # Development
    corepack_24
    nodejs_24
    deno
    android-tools
    # inputs.cargo-v5.packages.${pkgs.stdenv.hostPlatform.system}.cargo-v5-full

    # Games
    (prismlauncher.override {
      additionalLibs = [
        glfw
      ];
      jdks = [
        temurin-bin-8
        temurin-bin-21
        temurin-bin-25
      ];
    })
  ];

  programs.obs-studio = {
    enable = true;

    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi # optional AMD hardware acceleration
      obs-gstreamer
      obs-vkcapture
      (distroav.override {
        ndi-6 = (
          pkgs.ndi-6.overrideAttrs (oldAttrs: {
            # Upstream pushed 6.3.2 which is not in nixpkgs yet.
            version = "6.3.2";
            src = builtins.fetchurl {
              url = "https://downloads.ndi.tv/SDK/NDI_SDK_Linux/${oldAttrs.installerName}.tar.gz";
              sha256 = "sha256-8DFPJFRG3vxIi2POtGiazxqWWu79ray3BXG7IWqMwYM=";
            };
          })
        );
      })
    ];
  };
}
