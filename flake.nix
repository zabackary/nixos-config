{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source, using the nixos-25.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Flatpaks
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.6.0";

    # LINE
    line-messenger.url = "path:./line-messenger";
    # FreeShow
    freeshow.url = "path:./freeshow";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      line-messenger,
      freeshow,
      nix-flatpak,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib // home-manager.lib;
    in
    {
      nixosConfigurations = {
        shinjitsu = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs;
          modules = [
            ./hosts/shinjitsu
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs;
              };
              home-manager.users.zabackary = ./home/zabackary.nix;
            }
          ];
        };
      };

      homeConfigurations = {
        "fish@pond" = lib.homeManagerConfiguration {
          modules = [
            ./home/fish/default.nix
          ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = {
            inherit inputs;
          };
        };
      };

    };
}
