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

        # Bail out quietly if we're offline, otherwise rclone spews a pile of
        # connection errors and trips the OnFailure notification.
        if ! ${pkgs.curl}/bin/curl --silent --show-error --fail --max-time 15 --output /dev/null https://clients3.google.com/generate_204; then
          echo "freeshow-media-sync: no internet connectivity; skipping sync"
          exit 0
        fi

        # bisync has no --error-on-no-transfer equivalent and always exits 0 on a
        # clean run, so we sniff its log output for the "no changes" line instead.
        status=0
        output="$(${pkgs.rclone}/bin/rclone bisync --config "$HOME/.config/rclone/rclone.conf" --resilient --progress --stats 1s --log-level INFO ~/Documents/FreeShow/Media "school_gdrive:SLC/Chapel Slides/Freeshow Media Sync CAJ" 2>&1)" || status=$?
        printf '%s\n' "$output"
        if [ "$status" -ne 0 ]; then
          exit "$status"
        fi

        if printf '%s\n' "$output" | ${pkgs.gnugrep}/bin/grep -qi 'No changes found'; then
          echo "freeshow-media-sync: rclone transferred no new files; skipping desktop notification"
        else
          # Pull the per-file operations out of rclone's INFO log lines, e.g.
          # "2026/01/01 12:00:00 INFO  : foo.png: Copied (new)", and turn them
          # into "+ foo.png" (new), "~ foo.png" (updated) or "- foo.png" (deleted).
          changes="$(printf '%s\n' "$output" \
            | ${pkgs.coreutils}/bin/tr -d '\r' \
            | ${pkgs.gnused}/bin/sed -nE \
                -e 's/.*INFO  : (.+): Copied \(new\)$/+ \1/p' \
                -e 's/.*INFO  : (.+): Copied \(replaced existing\)$/~ \1/p' \
                -e 's/.*INFO  : (.+): Deleted$/- \1/p' \
            | ${pkgs.coreutils}/bin/sort -u)"
          count="$(printf '%s' "$changes" | ${pkgs.gnugrep}/bin/grep -c . || true)"
          max_lines=10
          body="$(printf '%s\n' "$changes" | ${pkgs.coreutils}/bin/head -n "$max_lines")"
          if [ "$count" -gt "$max_lines" ]; then
            body="$(printf '%s\n…and %d more' "$body" "$((count - max_lines))")"
          fi
          ${pkgs.libnotify}/bin/notify-send 'Synced new media for FreeShow' "$body" --icon=dialog-information --urgency=low --app-name=freeshow-media-sync.service
        fi
      '';
    };
  };

  # Taildrop receiver: text/links shared from Android arrive as <32 hex>.txt or
  # <32 hex>.url; those get shown as notifications, anything else lands in Downloads.
  systemd.user.services.taildrop-receive = {
    Install.WantedBy = [ "graphical-session.target" ];
    Unit = {
      Description = "Receive Taildrop files and notify";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
      OnFailure = "notify-failure@%n.service";
    };
    Service = {
      Type = "simple";
      Restart = "always";
      RestartSec = "30s"; # tailscaled may not be up yet
      ExecStart = pkgs.writeShellScript "taildrop-receive.sh" ''
        set -euo pipefail
        export PATH=${
          lib.makeBinPath [
            pkgs.coreutils
            pkgs.gnugrep
            pkgs.tailscale
            pkgs.libnotify
            pkgs.wl-clipboard
            pkgs.xdg-utils
          ]
        }

        tmp="$(mktemp -d "''${XDG_RUNTIME_DIR:-/tmp}/taildrop.XXXXXX")"
        trap 'rm -rf "$tmp"' EXIT
        downloads="''${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
        mkdir -p "$downloads"

        # Runs in the background so a notification waiting for a click doesn't
        # block receiving more files.
        show_text() {
          local title="$1" text="$2" action
          action="$(notify-send --app-name=taildrop --icon=edit-paste --action=copy=Copy --wait "$title" "$text" || true)"
          if [ "$action" = copy ]; then
            printf '%s' "$text" | wl-copy
          fi
        }

        while true; do
          tailscale file get --wait --conflict=rename "$tmp"
          for f in "$tmp"/*; do
            [ -f "$f" ] || continue
            name="$(basename "$f")"
            if [[ "$name" =~ ^[0-9a-f]{32}\.(txt|url)$ ]]; then
              ext="''${BASH_REMATCH[1]}"
              content="$(cat "$f")"
              rm -f "$f"
              if [ "$ext" = url ]; then
                # Handle both a bare URL and a Windows-style [InternetShortcut] file.
                url="$(printf '%s\n' "$content" | tr -d '\r' | grep -m1 -oE 'https?://[^[:space:]]+' || true)"
                if [ -n "$url" ]; then
                  xdg-open "$url" >/dev/null 2>&1 &
                  show_text "Opened link from Taildrop" "$url" &
                  continue
                fi
              fi
              show_text "Text from Taildrop" "$content" &
            else
              mv --backup=numbered "$f" "$downloads/"
              notify-send --app-name=taildrop --icon=folder-download "File received via Taildrop" "$name (saved to Downloads)" &
            fi
          done
        done
      '';
    };
  };

  # systemd.user.services.tailscale-systray = {
  #   Install.WantedBy = [ "graphical-session.target" ];
  #   Unit = {
  #     Description = "Tailscale systray application";
  #     After = [ "graphical-session.target" ];
  #     PartOf = [ "graphical-session.target" ];
  #     OnFailure = "notify-failure@%n.service"; # Run failure notification service on failure
  #   };
  #   Service = {
  #     Type = "simple";
  #     ExecStart = "${pkgs.tailscale}/bin/tailscale systray";
  #     Restart = "on-failure";
  #     RestartSec = "30s"; # Wait 30 seconds before restarting on failure to avoid rapid restart loops
  #   };
  # };

  # # Music!
  # services.spotifyd = {
  #   enable = true;
  #   settings = {
  #     global = {
  #       username = "31ds2jm75bl7v2wenugicy5rjove";
  #       password_cmd = "kwallet-query -r \"31ds2jm75bl7v2wenugicy5rjove\" -f \"spotifyd\" kdewallet";
  #       device_name = "shinjitsu daemon";
  #       device_type = "computer";
  #       bitrate = 320;
  #       initial_volume = 70;
  #       volume_normalisation = true;
  #       backend = "pulseaudio";
  #     };
  #   };
  # };
  # systemd.user.services.spotifyd-restart = {
  #   Unit = {
  #     Description = "Restart spotifyd after resume";
  #     After = [ "suspend.target" ];
  #     OnFailure = "notify-failure@%n.service"; # Run failure notification service on failure
  #   };
  #   Service = {
  #     Type = "oneshot";
  #     ExecStart = "${pkgs.systemd}/bin/systemctl --user restart spotifyd.service";
  #   };
  #   Install = {
  #     WantedBy = [
  #       "suspend.target"
  #       "spotifyd.service"
  #     ];
  #   };
  # };

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
}
