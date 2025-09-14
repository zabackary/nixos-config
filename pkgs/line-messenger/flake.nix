{
  description = "A Nix flake for LINE";

  inputs = {
    erosanix.url = "github:emmanuelrosa/erosanix";
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };

  outputs =
    {
      self,
      nixpkgs,
      erosanix,
    }:
    {

      packages.x86_64-linux =
        let
          pkgs = import "${nixpkgs}" {
            system = "x86_64-linux";
          };

        in
        with (pkgs // erosanix.packages.x86_64-linux // erosanix.lib.x86_64-linux);
        {
          default = self.packages.x86_64-linux.line-messenger;

          line-messenger = callPackage ./line-messenger.nix {
            inherit
              mkWindowsAppNoCC
              makeDesktopIcon
              copyDesktopIcons
              ;

            wine = wineWowPackages.base;
          };
        };

      apps.x86_64-linux.line-messenger = {
        type = "app";
        program = "${self.packages.x86_64-linux.line-messenger}/bin/line-messenger";
      };

      apps.x86_64-linux.default = self.apps.x86_64-linux.line-messenger;
    };
}
