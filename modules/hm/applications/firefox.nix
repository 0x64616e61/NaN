{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.applications.firefox;
in
{
  options.custom.hm.applications.firefox = {
    enable = mkEnableOption "Firefox with Cascade theme";
    
    enableCascade = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Cascade theme for Firefox";
    };
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      
      profiles.default = {
        id = 0;
        name = "Default";
        isDefault = true;
        
        # Enable userChrome.css
        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          "svg.context-properties.content.enabled" = true;
          "layout.css.color-mix.enabled" = true;
          "browser.tabs.delayHidingAudioPlayingIconMS" = 0;
          "layout.css.backdrop-filter.enabled" = true;
          
          # Cascade recommended settings
          "browser.newtabpage.activity-stream.newtabWallpapers.enabled" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        };
        
        # Copy Cascade theme files
        userChrome = mkIf cfg.enableCascade ''
          /* Import Cascade theme */
          @import url("cascade-config.css");
          @import url("cascade-colours.css");
          @import url("cascade-layout.css");
          @import url("cascade-responsive.css");
          @import url("cascade-floating-panel.css");
          @import url("cascade-nav-bar.css");
          @import url("cascade-tabs.css");
        '';
      };
    };
    
    # Copy Cascade chrome folder to Firefox profile
    home.file = mkIf cfg.enableCascade {
      ".mozilla/firefox/default/chrome" = {
        source = ./cascade-chrome;
        recursive = true;
      };
    };
  };
}