{
  lib,
  appimageTools,
  fetchurl,
}:

let
  data = import ../../data/freeshow.nix;
  version = data.version;
  pname = "freeshow";

  src = fetchurl {
    url = "https://github.com/ChurchApps/FreeShow/releases/download/v${version}/FreeShow-${version}-x86_64.AppImage";
    hash = data.sha256;
  };

in
appimageTools.wrapType2 {
  inherit pname version src;

  meta = {
    description = "A dynamic, user-friendly, and open-source presenter built for all of your presentations.";
    homepage = "https://freeshow.app";
    downloadPage = "https://github.com/ChurchApps/FreeShow/releases";
    license = lib.licenses.gpl3;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ zabackary ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "freeshow";
  };
}
