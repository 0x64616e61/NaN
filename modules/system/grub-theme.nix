{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.grubTheme;
  
  # Vimix rotated theme for GPD Pocket 3
  vimixRotatedTheme = pkgs.stdenv.mkDerivation rec {
    pname = "grub2-vimix-rotated-theme";
    version = "1.0";
    
    src = ./vimix-theme-rotated;
    
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
      
      # Ensure font is present
      if [ ! -f $out/font.pf2 ]; then
        cp ${pkgs.grub2}/share/grub/unicode.pf2 $out/font.pf2
      fi
    '';
  };
in
{
  options.custom.system.grubTheme = {
    enable = mkEnableOption "custom GRUB theme for GPD Pocket 3";
  };

  config = mkIf cfg.enable {
    # Configure GRUB to use Vimix rotated theme
    boot.loader.grub = {
      theme = lib.mkForce vimixRotatedTheme;
      splashImage = lib.mkForce null; # We use the theme's background instead
      
      # Ensure fonts are loaded
      font = lib.mkForce "${vimixRotatedTheme}/font.pf2";
      fontSize = lib.mkForce 16;
    };
  };
}