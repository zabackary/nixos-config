{
  description = "A Nix flake for FreeShow";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux = let
      pkgs = import "${nixpkgs}" {
        system = "x86_64-linux";
      };

    in with (pkgs); {
      default = self.packages.x86_64-linux.freeshow;

      freeshow = callPackage ./freeshow.nix { };
    };

    apps.x86_64-linux.freeshow = {
      type = "app";
      program = "${self.packages.x86_64-linux.freeshow}/bin/freeshow";
    };

    apps.x86_64-linux.default = self.apps.x86_64-linux.freeshow;
  };
}
