{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # development tools like node, compilers, etc.
    ./development.nix
  ];

  # MARK: Bootloader
  # Bootloader for this machine, which uses grub with an OS prober because it is
  # a triple-boot Windows 11 Pro / Linux Mint / NixOS setup.
  boot.loader.grub = {
    enable = true;
    useOSProber = true;
    device = "nodev";
    efiSupport = true;
    configurationLimit = 10;
    extraEntries = ''
      menuentry "Restart" {
        reboot
      }
      menuentry "Shut down" {
        halt
      }
    '';
    # Nice splash screen with Roboto font
    splashImage = ../../assets/grub-background.png;
    gfxmodeEfi = "1920x1200,auto";
    theme = ../../assets/grub-theme;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  # MARK: Networking

  # IP, because it's sad to be alone.
  networking.hostName = "shinjitsu";
  networking.networkmanager.enable = true;
  networking.firewall.enable = true; # should be on by default anyway

  # There's a hardware (?) issue with the QCNFA765 network card in this laptop
  # that makes the system lock up after resuming from suspend using the default
  # ath11k_pci driver. The workaround is to disable the kernel module upon
  # suspend and re-enable it upon resume.
  systemd.services.ath11k-suspend-fix = {
    description = "Disable ath11k_pci on suspend";
    wantedBy = [ "suspend.target" ];
    before = [ "suspend.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = "/run/current-system/sw/bin/rmmod ath11k_pci";
    };
  };
  systemd.services.ath11k-resume-fix = {
    description = "Enable ath11k_pci on resume";
    wantedBy = [ "suspend.target" ];
    after = [ "suspend.target" ];
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = "/run/current-system/sw/bin/modprobe ath11k_pci";
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # cert for Synology NAS
  security.pki.certificates = [
    (builtins.readFile ../../data/synology.pem)
  ];

  # Printing

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      cups-filters
      cups-browsed
    ];
  };
  services.ipp-usb.enable = true;

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true; # Show battery charge of Bluetooth devices
      };
    };
  };

  # MARK: Formatting, timezone, internationalisation
  time.timeZone = "Asia/Tokyo";
  # services.automatic-timezoned.enable = true;
  # I'm in Japan and I want my locale to be US English but with
  # Japanese conventions for things like dates and numbers.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };

  # Input method framework
  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  # MARK: Desktop environment

  # Enable the X11 windowing system in addition to Wayland (default in Plasma 6).
  # Some programs still need X11.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable KDE Plasma.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # # Hyprland
  # programs.hyprland = {
  #   enable = true;
  #   xwayland.enable = true;
  # };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Disable hibernation (and corresponding UI elements in Plasma) since I don't
  # use it and haven't set it up properly.
  systemd.sleep.extraConfig = ''
    AllowHibernation=no
  '';

  # MARK: Users and permissions
  users.users.zabackary = {
    isNormalUser = true;
    description = "Zachary Cheng";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
    ];
    packages = with pkgs; [
      kdePackages.kate
      #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # MARK: System packages
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    bash
    imagemagickBig
    inputs.line-messenger.packages.x86_64-linux.line-messenger
    inputs.freeshow.packages.x86_64-linux.freeshow
    borgbackup
    linux-wifi-hotspot

    # Rounded corners for windows
    kde-rounded-corners
  ];

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    fira-code
    fira-code-symbols
    nerd-fonts.fira-code
    montserrat
    roboto
    roboto-mono
    roboto-flex
    roboto-serif
    roboto-slab
    nerd-fonts.roboto-mono
  ];
  fonts.enableDefaultPackages = true;

  # Flatpaks
  services.flatpak.enable = true;

  # Appimage
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # https://nixos.wiki/wiki/OBS_Studio
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Virtual Camera" exclusive_caps=1
  '';
  security.polkit.enable = true;

  # MARK: Hardware

  # turn off the mic LEDs because it doesn't work
  systemd.services.configure-mic-led = rec {
    wantedBy = [ "sound.target" ];
    after = wantedBy;
    serviceConfig.Type = "oneshot";
    script = ''
      echo off > /sys/class/sound/ctl-led/mic/mode
    '';
  };

  # Fingerprint
  services.fprintd.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
