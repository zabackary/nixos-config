{
  description = "A Nix flake for RustDesk";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };

  outputs =
    { self, nixpkgs }:
    {

      packages.x86_64-linux =
        let
          pkgs = import "${nixpkgs}" {
            system = "x86_64-linux";
          };

        in
        with (pkgs);
        {
          default = self.packages.x86_64-linux.rustdesk;

          rustdesk = callPackage ./rustdesk.nix { };
        };

      apps.x86_64-linux.rustdesk = {
        type = "app";
        program = "${self.packages.x86_64-linux.rustdesk}/bin/rustdesk";
      };

      apps.x86_64-linux.default = self.apps.x86_64-linux.rustdesk;
    };
}
