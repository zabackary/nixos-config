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

    # FreeShow
    freeshow.url = "path:./pkgs/freeshow";
    freeshow.inputs.nixpkgs.follows = "nixpkgs";
    # LINE
    line-messenger.url = "path:./pkgs/line-messenger";
    line-messenger.inputs.nixpkgs.follows = "nixpkgs";

    # Browser Previews for up-to-date Chrome versions without updating Nixpkgs
    browser-previews.url = "github:nix-community/browser-previews";
    browser-previews.inputs.nixpkgs.follows = "nixpkgs";

    # cargo-v5 tool for vexide projects
    cargo-v5.url = "github:vexide/cargo-v5";
    cargo-v5.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib // home-manager.lib;
    in
    {
      nixosConfigurations = {
        shinjitsu = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/shinjitsu
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs;
              };
              home-manager.users.zabackary = ./home/zabackary/default.nix;
            }
          ];
        };
      };

      homeConfigurations = {
        "fish" = lib.homeManagerConfiguration {
          modules = [
            ./home/fish/default.nix
          ];
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          extraSpecialArgs = {
            inherit inputs;
          };
        };
      };

    };
}
