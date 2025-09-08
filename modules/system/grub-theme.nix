{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.grubTheme;
  
  # Globe theme package
  globeGrubTheme = pkgs.stdenv.mkDerivation rec {
    pname = "grub-theme-globe";
    version = "1.0";
    
    src = ./grub-theme/globe-theme;
    
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
    enable = mkEnableOption "custom GRUB theme with globe animation style";
  };

  config = mkIf cfg.enable {
    # Configure GRUB to use our theme
    boot.loader.grub = {
      theme = lib.mkForce globeGrubTheme;
      splashImage = lib.mkForce null; # We use the theme's background instead
      
      # Ensure fonts are loaded
      font = lib.mkForce "${globeGrubTheme}/font.pf2";
      fontSize = lib.mkForce 16;
    };
  };
}