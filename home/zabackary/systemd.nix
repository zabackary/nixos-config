{
  lib,
  inputs,
  pkgs,
  ...
}:
{
  systemd.user.timers.freeshow-media-sync = {
    Unit.Description = "Timer to sync media for FreeShow every hour";
    Timer = {
      OnCalendar = "*-*-* *:00:00"; # Run every hour on the hour
      OnBootSec = "1min"; # Also run 1 minute after boot
      RandomizedDelaySec = "5m"; # Add a random delay of up to 5 minutes to avoid thundering herd problem
    };
    Install = {
      WantedBy = [ "timers.target" ]; # Ensure the timer is started when timers.target is active
    };
  };

  # systemd.paths.freeshow-media-sync = {
  #   Unit = {
  #     Description = "Path unit to trigger FreeShow media sync on changes";
  #   };
  #   Path = {
  #     PathModified = "$HOME/Documents/FreeShow/Media"; # Watch for modifications in the media directory
  #     PathExists = "$HOME/Documents/FreeShow/Media"; # Ensure the path exists before starting the service
  #   };
  #   Install.WantedBy = [ "multi-user.target" ]; # Ensure the path unit is started when multi-user.target is active
  # };

  systemd.user.services.freeshow-media-sync = {
    Unit = {
      Description = "Sync media for FreeShow using rclone";
      After = [ "network.target" ]; # Ensure network is available before running
      OnFailure = "notify-failure@%n.service"; # Run failure notification service on failure
    };
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "freeshow-media-sync.sh" ''
        set -eou pipefail
        ${pkgs.rclone}/bin/rclone bisync --config "$HOME/.config/rclone/rclone.conf" --resilient --progress --stats 1s --log-level INFO --log-file "$HOME/.cache/freeshow-media-sync.log" ~/Documents/FreeShow/Media "school_gdrive:SLC/Chapel Slides/Freeshow Media Sync CAJ"
        ${pkgs.libnotify}/bin/notify-send 'Synced media for FreeShow' --icon=dialog-information --urgency=low --app-name=freeshow-media-sync.service
      '';
      RemainAfterExit = true; # Prevents the service from automatically starting on rebuild. See https://discourse.nixos.org/t/how-to-prevent-custom-systemd-service-from-restarting-on-nixos-rebuild-switch/43431
    };
  };

  systemd.user.services.tailscale-systray = {
    Install.WantedBy = [ "graphical-session.target" ];
    Unit = {
      Description = "Tailscale systray application";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      OnFailure = "notify-failure@%n.service"; # Run failure notification service on failure
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.tailscale}/bin/tailscale systray";
      Restart = "on-failure";
      RestartSec = "30s"; # Wait 30 seconds before restarting on failure to avoid rapid restart loops
    };
  };

  # Failure notification handler service
  systemd.user.services."notify-failure@" = {
    Unit = {
      Description = "Notify user of a failed systemd unit";
    };
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "notify-failure.sh" ''
        set -eou pipefail
        ${pkgs.libnotify}/bin/notify-send --urgency=critical "user systemd service failure" "Job for $FAILED_UNIT failed. See 'journalctl --user -xeu $FAILED_UNIT' for details." --app-name=notify-failure.service --icon=dialog-error
      '';
      Environment = "FAILED_UNIT=%i";
    };
  };

  # Music!
  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        username = "31ds2jm75bl7v2wenugicy5rjove";
        password_cmd = "kwallet-query -r \"31ds2jm75bl7v2wenugicy5rjove\" -f \"spotifyd\" kdewallet";
        device_name = "shinjitsu daemon";
        device_type = "computer";
        bitrate = 320;
        initial_volume = 70;
        volume_normalisation = true;
        backend = "pulseaudio";
      };
    };
  };
  systemd.user.services.spotifyd-restart = {
    Unit = {
      Description = "Restart spotifyd after resume";
      After = [ "suspend.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl --user restart spotifyd.service";
    };
    Install = {
      WantedBy = [
        "suspend.target"
        "spotifyd.service"
      ];
    };
  };
}
