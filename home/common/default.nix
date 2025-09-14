{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  home = {
    username = lib.mkDefault "zabackary";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "22.05";

    sessionVariables = {
      XDG_DATA_DIRS = "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
    };
  };

  # Flatpaks
  services.flatpak.update.auto.enable = false;
  services.flatpak.uninstallUnmanaged = true;
  # flatpak packages are in flatpak.nix

  home.packages = with pkgs; [
    starship
    neofetch
    fastfetch
    ripgrep
    cowsay # why not
    file
    which
    tree
    bat
    gnused
    gnutar
    gawk
    zstd
    gnupg

    # system utils
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    p7zip # 7z

    # nix things
    nixfmt-rfc-style
    nixd
  ];

  # MARK: Shell configuration

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = '''';

    shellAliases = {
      pn = "pnpm";
    };
  };

  # My starship prompt. It is basically purple.
  programs.starship = {
    enable = true;
    settings = {
      format = "[░▒▓](#B6B6FC)[ $username$hostname$localip󰣭 ](bg:#B6B6FC fg:#090c0c)[](bg:#9D9DDA fg:#B6B6FC)$directory[](fg:#9D9DDA bg:#545474)$git_branch$git_status[](fg:#545474) $all$character";
      palette = "all_purple";
      character = {
        success_symbol = "[❯](bold fg:#B6B6FC)";
        error_symbol = "[❯](bold fg:#FCB792)";
      };
      directory = {
        style = "fg:#3B3B52 bg:#9D9DDA";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncate_to_repo = true;
        truncation_symbol = "…/";
        substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = " ";
          "Pictures" = " ";
        };
      };
      git_branch = {
        symbol = "";
        style = "bg:#545474";
        format = "[[ $symbol $branch ](fg:#B6B6FC bg:#545474)]($style)";
      };
      git_status = {
        style = "bg:#545474";
        format = "[[($all_status$ahead_behind )](fg:#B6B6FC bg:#545474)]($style)";
      };
      package.style = "bold fg:#B6B6FC";
      palettes.all_purple = {
        red = "#B6B6FC";
        green = "#B6B6FC";
        yellow = "#B6B6FC";
        blue = "#B6B6FC";
        purple = "#B6B6FC";
        cyan = "#B6B6FC";
        orange = "#B6B6FC";
        bright-cyan = "#B6B6FC";
      };
    };
  };

  # Random CLI tools
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    userName = "zabackary";
    userEmail = "137591653+zabackary@users.noreply.github.com";
    lfs.enable = true;
    extraConfig = {
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };
}
