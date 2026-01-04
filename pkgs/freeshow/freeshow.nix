{
  lib,
  appimageTools,
  fetchurl,
}:

let
  version = "1.5.5";
  pname = "freeshow";

  src = fetchurl {
    url = "https://github.com/ChurchApps/FreeShow/releases/download/v${version}/FreeShow-${version}-x86_64.AppImage";
    hash = "sha256-7sVGi/1VkyrMKg5kEm0slvC6TPnUUC78Y/ZJ0/WFefw=";
  };

  appimageContents = appimageTools.extractType1 { inherit src; name = pname; };
in
appimageTools.wrapType2 rec {
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
