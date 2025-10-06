{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.audio.easyeffects;
in
{
  options.custom.hm.audio.easyeffects = {
    enable = mkEnableOption "EasyEffects audio processing";
    
    package = mkOption {
      type = types.package;
      default = pkgs.easyeffects;
      description = "EasyEffects package to use";
    };
    
    preset = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "Meze_109_Pro";
      description = "Preset to automatically load";
    };
    
    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = "Start EasyEffects automatically";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    
    services.easyeffects = {
      enable = true;
      preset = mkIf (cfg.preset != null) cfg.preset;
    };
  };
}