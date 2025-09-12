{
  inputs,
  ...
}:
let
  # Package configuration - sets up package system with proper overlays
  # Most users won't need to modify this section
  pkgs = import inputs.hydenix.inputs.hydenix-nixpkgs {
    inherit (inputs.hydenix.lib) system;
    config.allowUnfree = true;
    overlays = [
      inputs.hydenix.lib.overlays
      (final: prev: {
        userPkgs = import inputs.nixpkgs {
          config.allowUnfree = true;
        };
      })
    ];
  };
in
{
  nixpkgs.pkgs = pkgs; # Set pkgs for hydenix globally

  imports = [
    # hydenix inputs - Required modules, don't modify unless you know what you're doing
    inputs.hydenix.inputs.home-manager.nixosModules.home-manager
    inputs.hydenix.lib.nixOsModules
    ./modules/system # Your custom system modules
    ./modules/system/update-alias.nix # Update! command for quick commits and rebuilds
    ./hardware-config.nix # Hardware configuration wrapper

    # Hardware Configuration - Uncomment lines that match your hardware
    # Run `lshw -short` or `lspci` to identify your hardware

    # GPU Configuration (choose one):
    # inputs.hydenix.inputs.nixos-hardware.nixosModules.common-gpu-nvidia # NVIDIA
    # inputs.hydenix.inputs.nixos-hardware.nixosModules.common-gpu-amd # AMD

    inputs.hydenix.inputs.nixos-hardware.nixosModules.gpd-pocket-3

    # CPU Configuration (choose one):
    # inputs.hydenix.inputs.nixos-hardware.nixosModules.common-cpu-amd # AMD CPUs
    # inputs.hydenix.inputs.nixos-hardware.nixosModules.common-cpu-intel # Intel CPUs

    # Additional Hardware Modules - Uncomment based on your system type:
    # inputs.hydenix.inputs.nixos-hardware.nixosModules.common-hidpi # High-DPI displays
    # inputs.hydenix.inputs.nixos-hardware.nixosModules.common-pc-laptop # Laptops
    # inputs.hydenix.inputs.nixos-hardware.nixosModules.common-pc-ssd # SSD storage
  ];

  # If enabling NVIDIA, you will be prompted to configure hardware.nvidia

  # Set system-wide default terminal
  environment.sessionVariables = {
    TERMINAL = "ghostty";
  };
  # hardware.nvidia = {
  #   open = true; # For newer cards, you may want open drivers
  #   prime = { # For hybrid graphics (laptops), configure PRIME:
  #     amdBusId = "PCI:0:2:0"; # Run `lspci | grep VGA` to get correct bus IDs
  #     intelBusId = "PCI:0:2:0"; # if you have intel graphics
  #     nvidiaBusId = "PCI:1:0:0";
  #     offload.enable = false; # Or disable PRIME offloading if you don't care
  #   };
  # };

  # Home Manager Configuration - manages user-specific configurations (dotfiles, themes, etc.)
  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs; };
    # User Configuration - REQUIRED: Change "hydenix" to your actual username
    # This must match the username you define in users.users below
    users."a" =
      { ... }:
      {
        imports = [
          inputs.hydenix.lib.homeModules
          inputs.nix-index-database.hmModules.nix-index # Command-not-found and comma tool support
          ./modules/hm # Your custom home-manager modules (configure hydenix.hm here!)
        ];
      };
  };

  # User Account Setup - REQUIRED: Change "hydenix" to your desired username (must match above)
  users.users.a = {
    isNormalUser = true;
    initialPassword = "a"; # SECURITY: Change this password after first login with `passwd`
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "input"  # Required for gesture recognition
      "users"  # Required for Vial keyboard access
    ]; # User groups (determines permissions)
    shell = pkgs.zsh; # Default shell (options: pkgs.bash, pkgs.zsh, pkgs.fish)
  };

  # Hydenix Configuration - Main configuration for the Hydenix desktop environment
  hydenix = {
    enable = true; # Enable Hydenix modules
    # Basic System Settings (REQUIRED):
    hostname = "mini"; # REQUIRED: Set your computer's network name (change to something unique)
    timezone = "Europe/London"; # REQUIRED: Set timezone (examples: "America/New_York", "Europe/London", "Asia/Tokyo")
    locale = "en_GB.UTF-8"; # REQUIRED: Set locale/language (examples: "en_US.UTF-8", "en_GB.UTF-8", "de_DE.UTF-8")
    # For more configuration options, see: ./docs/options.md
  };
  
  # Firewall configuration for Unified Remote
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 9510 9511 9512 ];  # Unified Remote ports
    allowedUDPPorts = [ 9510 9511 9512 ];  # Unified Remote discovery
  };
  
  # iPhone USB tethering support
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;  # Use newer implementation for better iOS 14+ support
  };


  # System Version - Don't change unless you know what you're doing (helps with system upgrades and compatibility)
  system.stateVersion = "25.05";
}
