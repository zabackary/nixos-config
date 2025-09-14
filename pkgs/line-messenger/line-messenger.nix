{
  stdenv,
  lib,
  mkWindowsAppNoCC,
  imagemagick,
  wine,
  fetchurl,
  makeDesktopItem,
  copyDesktopItems,
  copyDesktopIcons, # This comes with erosanix. It's a handy way to generate desktop icons.
  unzip,
}:

mkWindowsAppNoCC rec {
  inherit wine;

  pname = "line-messenger";
  version = "8.7.0.3303";

  src = builtins.fetchurl {
    # obtained from https://store.rg-adguard.net/
    # since there seems to be no provided canonical URL for each version, the sha will have to be updated appropriately.
    url = "https://desktop.line-scdn.net/win/bin/real/installer/legacy/LineInst.exe";
    sha256 = "sha256:60746c3d1a382481ccb45c3eb83669ec5fa552f018354b771f6d7782aac9b1de";
  };

  dontUnpack = true;
  wineArch = "win64";
  persistRegistry = false;
  persistRuntimeLayer = true;
  enableMonoBootPrompt = false;
  graphicsDriver = "auto"; # Note: Does not work with Wayland
  nativeBuildInputs = [
    copyDesktopItems
    copyDesktopIcons
  ];

  fileMap = {
    "$HOME/.local/share/line/Data" = "drive_c/users/$USER/AppData/Local/LINE/Data";
    "$HOME/.local/share/line-call/Data" = "drive_c/users/$USER/AppData/Local/LineCall/Data";
  };

  enabledWineSymlinks = {
    desktop = false;
  };

  enableInstallNotification = true;
  inhibitIdle = false;

  winAppInstall = ''
    winetricks win10
    $WINE ${src} /S
    wineserver -w
    mkdir -p "$WINEPREFIX/drive_c/users/$USER/AppData/Local/LINE/Data"

  '';

  # This code runs before winAppRun, but only for the first instance.
  # Therefore, if the app is already running, winAppRun will not execute.
  # Use this to do any setup prior to running the app.
  winAppPreRun = '''';

  winAppRun = ''
    $WINE start /unix "$WINEPREFIX/drive_c/users/$USER/AppData/Local/LINE/bin/LineLauncher.exe"
  '';

  # This code will run after winAppRun, but only for the first instance.
  # Therefore, if the app was already running, winAppPostRun will not execute.
  # In other words, winAppPostRun is only executed if winAppPreRun is executed.
  # Use this to do any cleanup after the app has terminated
  winAppPostRun = "";

  # This is a normal mkDerivation installPhase, with some caveats.
  # The launcher script will be installed at $out/bin/.launcher
  # DO NOT DELETE OR RENAME the launcher. Instead, link to it as shown.
  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/${pname}

    runHook postInstall
  '';

  desktopItems = (
    makeDesktopItem {
      name = pname;
      exec = pname;
      icon = pname;
      desktopName = "LINE";
      categories = [
        "Network"
        "Chat"
      ];
    }
  );

  desktopIcon = makeDesktopItem {
    name = "LINE Messenger";

    src = fetchurl {
      url = "https://www.line.me/static/b83de682148ca1092750bd59456ca0d9/c0a13/28e883fa1eef1f2e2aca961e12498120.png";
      sha256 = "sha256-0fJ4FDLg7dkIPqh0y5tqe/hw78fEJpWvRwe1scjyWyo=";
    };
  };

  meta = with lib; {
    description = "A communication app that connects people, services, and information.";
    homepage = "https://www.line.me";
    license = licenses.unfree;
    maintainers = with maintainers; [ zabackary ];
    platforms = [ "x86_64-linux" ];
  };
}
