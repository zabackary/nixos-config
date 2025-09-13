{ pkgs, nix-flatpak,  ... }:

{
  imports = [
    nix-flatpak.homeManagerModules.nix-flatpak
    ./flatpak.nix
  ];

  home.sessionVariables = {
    XDG_DATA_DIRS="$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
  };

  home.username = "zabackary";
  home.homeDirectory = "/home/zabackary";

  home.packages = with pkgs; [
    starship
    neofetch
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
    alacritty

    # nix things
    nixfmt-rfc-style

    # more gui apps
    gimp3-with-plugins
    inkscape-with-extensions
    openshot-qt
    remmina
     
    p7zip
    kdePackages.plasma-browser-integration
    
    hunspell
    hunspellDicts.en_US
    
    parted
    gnome-disk-utility
  ];

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = '''';

    # set some aliases, feel free to add more or remove some
    shellAliases = {
      pn = "pnpm";
    };
  };

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
  
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };
  
  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };

  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "25.05";
}
