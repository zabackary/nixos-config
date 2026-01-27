{
  lib,
  appimageTools,
  fetchurl,
}:

let
  data = import ../../data/rustdesk.nix;
  version = data.version;
  pname = "rustdesk";

  src = fetchurl {
    url = "https://github.com/rustdesk/rustdesk/releases/download/${version}/rustdesk-${version}-x86_64.AppImage";
    hash = data.sha256;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  meta = {
    description = "The Fast Open-Source Remote Access and Support Software";
    homepage = "https://rustdesk.com";
    downloadPage = "https://github.com/rustdesk/rustdesk/releases";
    license = lib.licenses.gpl3;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ zabackary ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "rustdesk";
  };
}
