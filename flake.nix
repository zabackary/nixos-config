{
  description = "A simple NixOS flake";

  inputs = {
    # NixOS official package source
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # FIXME: remove once Zotero 11 comes out in nixpkgs
    nixpkgs-zotero.url = "github:NixOS/nixpkgs/7a0f122f5090cf4c2ade2a13a0e229d4e19ba71f";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Flatpaks
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";

    # FreeShow
    freeshow.url = "path:./pkgs/freeshow";
    freeshow.inputs.nixpkgs.follows = "nixpkgs";

    # Browser Previews for up-to-date Chrome versions without updating Nixpkgs
    browser-previews.url = "github:nix-community/browser-previews";
    browser-previews.inputs.nixpkgs.follows = "nixpkgs";

    kwin-effects-better-blur-dx.url = "github:xarblu/kwin-effects-better-blur-dx";
    kwin-effects-better-blur-dx.inputs.nixpkgs.follows = "nixpkgs";

    # Claude Desktop
    claude-desktop.url = "github:aaddrick/claude-desktop-debian";
    claude-desktop.inputs.nixpkgs.follows = "nixpkgs";
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
