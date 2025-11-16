{
  lib,
  appimageTools,
  fetchurl,
}:

let
  version = "1.4.3";
  pname = "rustdesk";

  src = fetchurl {
    url = "https://github.com/rustdesk/rustdesk/releases/download/${version}/rustdesk-${version}-x86_64.AppImage";
    hash = "sha256-ggvpqVg2sfeFC31OgdG+N+kNZdYsAX7CPBLsJAt1iQM=";
  };

  appimageContents = appimageTools.extractType1 {
    inherit src;
    name = pname;
  };
in
appimageTools.wrapType2 rec {
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
