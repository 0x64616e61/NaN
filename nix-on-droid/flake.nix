{
  description = "Nix-on-droid configuration for Pixel 9 Pro";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-on-droid }: {
    nixOnDroidConfigurations.pixel9pro = nix-on-droid.lib.nixOnDroidConfiguration {
      modules = [
        ./configuration.nix
      ];
    };
  };
}