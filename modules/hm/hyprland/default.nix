{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.hyprland;
in
{
  options.custom.hm.hyprland = {
    enable = mkEnableOption "Pure Nix Hyprland configuration";
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      
      settings = {
        # Main modifier
        "$mainMod" = "SUPER";
        
        # Monitor configuration for GPD Pocket 3
        monitor = "DSI-1,1200x1920@60,0x0,1.5,transform,3";
        
        # Execute on startup
        exec-once = [
          # Force landscape orientation for GPD Pocket 3
          "sleep 1 && hyprctl keyword monitor DSI-1,1200x1920@60,0x0,1.500000,transform,3"
          # Start waybar
          "${pkgs.waybar}/bin/waybar"
          # Start KeePassXC for secret service
          "keepassxc ~/Documents/Passwords.kdbx"
          # Start auto-rotate service
          "systemctl --user start auto-rotate-both"
          # Start dunst for notifications
          "${pkgs.dunst}/bin/dunst"
        ];
        
        # Environment variables
        env = [
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "QT_QPA_PLATFORM,wayland;xcb"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
          "MOZ_ENABLE_WAYLAND,1"
        ];
        
        # Input configuration
        input = {
          kb_layout = "us";
          follow_mouse = 1;
          touchpad = {
            natural_scroll = true;
          };
          accel_profile = "flat";
          numlock_by_default = true;
        };
        
        # General configuration
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.active_border" = mkForce "rgba(ccccccee)";
          "col.inactive_border" = mkForce "rgba(333333aa)";
          layout = "dwindle";
          allow_tearing = false;
        };
        
        # Decoration
        decoration = {
          rounding = 0;
          blur = {
            enabled = false;  # Disable for OLED optimization
            size = 3;
            passes = 1;
          };
          shadow = {
            enabled = false;  # Disable for OLED optimization
            range = 4;
            render_power = 3;
          };
        };
        
        # Animations
        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };
        
        # Layout
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };
        
        # Gestures
        gestures = {
          workspace_swipe = true;
        };
        
        # Misc
        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          vrr = 0;
        };
        
        # Window rules
        windowrulev2 = [
          "float,class:^(pavucontrol)$"
          "float,class:^(blueman-manager)$"
          "float,class:^(nm-connection-editor)$"
        ];
        
        # Keybindings
        bind = [
          # Core bindings
          "$mainMod, Q, killactive"
          "$mainMod, M, exit"
          "$mainMod, V, togglefloating"
          "$mainMod, P, pseudo"
          "$mainMod, J, togglesplit"
          "$mainMod, F, fullscreen"
          
          # Application launches
          "$mainMod, T, exec, ${pkgs.ghostty}/bin/ghostty"
          "$mainMod, E, exec, ${pkgs.kdePackages.dolphin}/bin/dolphin"
          "$mainMod, B, exec, ${pkgs.firefox}/bin/firefox"
          
          # dmenu launcher
          "$mainMod, SPACE, exec, ${pkgs.dmenu-wayland}/bin/dmenu-wl_run -b -p 'Run: ' -fn 'monospace:size=10' -nb '#1a1a1a' -nf '#cccccc' -sb '#333333' -sf '#ffffff' -h 25"
          
          # Move focus
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"
          
          # Switch workspaces
          "$mainMod, 1, workspace, 1"
          "$mainMod, 2, workspace, 2"
          "$mainMod, 3, workspace, 3"
          "$mainMod, 4, workspace, 4"
          "$mainMod, 5, workspace, 5"
          "$mainMod, 6, workspace, 6"
          "$mainMod, 7, workspace, 7"
          "$mainMod, 8, workspace, 8"
          "$mainMod, 9, workspace, 9"
          "$mainMod, 0, workspace, 10"
          
          # Move active window to workspace
          "$mainMod SHIFT, 1, movetoworkspace, 1"
          "$mainMod SHIFT, 2, movetoworkspace, 2"
          "$mainMod SHIFT, 3, movetoworkspace, 3"
          "$mainMod SHIFT, 4, movetoworkspace, 4"
          "$mainMod SHIFT, 5, movetoworkspace, 5"
          "$mainMod SHIFT, 6, movetoworkspace, 6"
          "$mainMod SHIFT, 7, movetoworkspace, 7"
          "$mainMod SHIFT, 8, movetoworkspace, 8"
          "$mainMod SHIFT, 9, movetoworkspace, 9"
          "$mainMod SHIFT, 0, movetoworkspace, 10"
          
          # Special workspace (scratchpad)
          "$mainMod, S, togglespecialworkspace"
          "$mainMod SHIFT, S, movetoworkspace, special"
          
          # Scroll through workspaces
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
        ];
        
        # Mouse bindings
        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
      };
    };
  };
}