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
      })).fhs
    )

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
    zed-editor
    # inputs.cargo-v5.packages.${pkgs.stdenv.hostPlatform.system}.cargo-v5-full

    # Games
    (prismlauncher.override {
      jdks = [
        temurin-bin-8
        temurin-bin-21
        temurin-bin-25
      ];
    })
  ];

  # # Noktalia and hyperland
  # wayland.windowManager.hyprland = {
  #   enable = true;
  #   settings = {
  #     "$mod" = "SUPER";

  #     monitor = ",preferred,auto,auto";

  #     general = {
  #       gaps_in = 5;
  #       gaps_out = 10;

  #       border_size = 2;

  #       col = {
  #         active_border = "rgba(33ccffee) rgba(00ff99ee) 45deg";
  #         inactive_border = "rgba(595959aa)";
  #       };

  #       # Set to true enable resizing windows by clicking and dragging on borders and gaps
  #       resize_on_border = false;

  #       # Please see Hyprland docs before you turn this on
  #       allow_tearing = false;

  #       layout = "dwindle";
  #     };

  #     decoration = {
  #       rounding = 20;
  #       rounding_power = 2;

  #       active_opacity = 1.0;
  #       inactive_opacity = 1.0;

  #       shadow = {
  #         enabled = true;
  #         range = 4;
  #         render_power = 3;
  #         color = "rgba(1a1a1aee)";
  #       };

  #       blur = {
  #         enabled = true;
  #         size = 3;
  #         passes = 12;
  #         vibrancy = 0.1696;
  #       };
  #     };

  #     animations = {
  #       enabled = true;
  #       bezier = [
  #         "easeOutQuint,   0.23, 1,    0.32, 1"
  #         "easeInOutCubic, 0.65, 0.05, 0.36, 1"
  #         "linear,         0,    0,    1,    1"
  #         "almostLinear,   0.5,  0.5,  0.75, 1"
  #         "quick,          0.15, 0,    0.1,  1"
  #       ];
  #       animation = [
  #         "global,        1,     10,    default"
  #         "border,        1,     5.39,  easeOutQuint"
  #         "windows,       1,     4.79,  easeOutQuint"
  #         "windowsIn,     1,     4.1,   easeOutQuint, popin 87%"
  #         "windowsOut,    1,     1.49,  linear,       popin 87%"
  #         "fadeIn,        1,     1.73,  almostLinear"
  #         "fadeOut,       1,     1.46,  almostLinear"
  #         "fade,          1,     3.03,  quick"
  #         "layers,        1,     3.81,  easeOutQuint"
  #         "layersIn,      1,     4,     easeOutQuint, fade"
  #         "layersOut,     1,     1.5,   linear,       fade"
  #         "fadeLayersIn,  1,     1.79,  almostLinear"
  #         "fadeLayersOut, 1,     1.39,  almostLinear"
  #         "workspaces,    1,     1.94,  almostLinear, fade"
  #         "workspacesIn,  1,     1.21,  almostLinear, fade"
  #         "workspacesOut, 1,     1.94,  almostLinear, fade"
  #         "zoomFactor,    1,     7,     quick"
  #       ];
  #     };

  #     terminal = "ghostty";
  #     file-manager = "dolphin";

  #     # Keybinds (main)
  #     bind = [
  #       "SUPER, Q, exec, $terminal"
  #       "SUPER, C, killactive,"
  #       "SUPER, M, exec, command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch exit"
  #       "SUPER, E, exec, $fileManager"
  #       "SUPER, V, togglefloating,"
  #       "SUPER, R, exec, $menu"
  #       "SUPER, P, pseudo,"
  #       "SUPER, J, layoutmsg, togglesplit"

  #       "SUPER, left, movefocus, l"
  #       "SUPER, right, movefocus, r"
  #       "SUPER, up, movefocus, u"
  #       "SUPER, down, movefocus, d"

  #       "SUPER, 1, workspace, 1"
  #       "SUPER, 2, workspace, 2"
  #       "SUPER, 3, workspace, 3"
  #       "SUPER, 4, workspace, 4"
  #       "SUPER, 5, workspace, 5"
  #       "SUPER, 6, workspace, 6"
  #       "SUPER, 7, workspace, 7"
  #       "SUPER, 8, workspace, 8"
  #       "SUPER, 9, workspace, 9"
  #       "SUPER, 0, workspace, 10"

  #       "SUPER SHIFT, 1, movetoworkspace, 1"
  #       "SUPER SHIFT, 2, movetoworkspace, 2"
  #       "SUPER SHIFT, 3, movetoworkspace, 3"
  #       "SUPER SHIFT, 4, movetoworkspace, 4"
  #       "SUPER SHIFT, 5, movetoworkspace, 5"
  #       "SUPER SHIFT, 6, movetoworkspace, 6"
  #       "SUPER SHIFT, 7, movetoworkspace, 7"
  #       "SUPER SHIFT, 8, movetoworkspace, 8"
  #       "SUPER SHIFT, 9, movetoworkspace, 9"
  #       "SUPER SHIFT, 0, movetoworkspace, 10"

  #       "SUPER, S, togglespecialworkspace, magic"
  #       "SUPER SHIFT, S, movetoworkspace, special:magic"

  #       "SUPER, mouse_down, workspace, e+1"
  #       "SUPER, mouse_up, workspace, e-1"
  #     ];

  #     bindm = [
  #       "SUPER, mouse:272, movewindow"
  #       "SUPER, mouse:273, resizewindow"
  #     ];

  #     bindel = [
  #       ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
  #       ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
  #       ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
  #       ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
  #       ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
  #       ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
  #     ];

  #     bindl = [
  #       ", XF86AudioNext, exec, playerctl next"
  #       ", XF86AudioPause, exec, playerctl play-pause"
  #       ", XF86AudioPlay, exec, playerctl play-pause"
  #       ", XF86AudioPrev, exec, playerctl previous"
  #     ];

  #     exec-once = [
  #       "qs -c noctalia-shell --no-duplicate"
  #     ];

  #     layerrule = [
  #       "ignorealpha 0.5, noctalia-background-.*"
  #       "blur, noctalia-background-.*"
  #       "blurpopups, noctalia-background-.*"
  #     ];

  #     dwindle = {
  #       pseudotile = true;
  #       preserve_split = true;
  #     };

  #     master = {
  #       new_status = "master";
  #     };

  #     misc = {
  #       force_default_wallpaper = -1;
  #       disable_hyprland_logo = false;
  #     };

  #     input = {
  #       kb_layout = "us";
  #       kb_variant = "";
  #       kb_model = "";
  #       kb_options = "";
  #       kb_rules = "";

  #       follow_mouse = 1;

  #       sensitivity = 0;

  #       touchpad = {
  #         natural_scroll = false;
  #       };
  #     };

  #     gesture = "3, horizontal, workspace";
  #   };
  # };
  # programs.noctalia-shell = {
  #   enable = true;
  # };
}
