{ config, pkgs, ... }:

{
  imports = [
    ./gpd-pocket-3.nix
    ./hardware-config.nix
    ./modules/system
  ];

  # Networking
  networking.hostName = "grOSs";
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;

  # Time zone and locale
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # User account
  users.users.a = {
    isNormalUser = true;
    description = "a";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "input"
      "users"
    ];
    # SECURITY: No default password - must be set manually after first boot
    # Set password with: sudo passwd a
    # Or use hashedPassword for declarative configuration:
    # hashedPassword = "...";  # Generate with: mkpasswd -m sha-512
    shell = pkgs.zsh;
  };

  # Enable zsh
  programs.zsh.enable = true;

  # Enable X server and display manager
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;  # Force X11 mode
  };

  # Fix SDDM greeter Qt platform plugin crash
  systemd.services.display-manager.environment = {
    QT_QPA_PLATFORM = "xcb";  # Force X11/xcb platform for greeter
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # iPhone USB tethering
  services.usbmuxd = {
    enable = true;
    package = pkgs.usbmuxd2;
  };

  # System state version
  system.stateVersion = "25.05";
}
