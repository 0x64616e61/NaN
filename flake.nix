{
  description = "NaN - Production NixOS configuration for GPD Pocket 3";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware }: {
    nixosConfigurations.NaN = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      
      modules = [
        # Hardware profile
        nixos-hardware.nixosModules.gpd-pocket-3
        
        # Main configuration
        ./configuration.nix
        
        # Home Manager integration
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.a = import ./modules/hm;
        }
      ];
    };
  };
}
