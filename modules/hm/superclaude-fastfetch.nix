{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.superclaudeFastfetch;
in
{
  options.custom.hm.superclaudeFastfetch = {
    enable = mkEnableOption "SuperClaude Framework compliant fastfetch";
  };

  config = mkIf cfg.enable {
    # Reboot-safe fastfetch service with proper dependencies
    systemd.user.services.superclaude-fastfetch = {
      enable = true;
      description = "SuperClaude Framework fastfetch service";
      after = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      wantedBy = [ "graphical-session.target" ];

      # Reboot-safe service requirements
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "5";

        # Resource limits for system stability
        MemoryMax = "128M";
        CPUQuota = "25%";

        # Standard environment for consistency
        Environment = [
          "TERM=xterm-256color"
          "COLUMNS=120"
          "LINES=40"
        ];

        # Dynamic execution with system variable pattern
        ExecStart = "${pkgs.nix}/bin/nix-shell -p 'nix bash coreutils systemd fastfetch' --run 'echo SuperClaude fastfetch ready'";
      };
    };

    # Install fastfetch with dynamic system dependencies
    home.packages = with pkgs; [
      fastfetch
      # Dynamic system dependencies for reboot safety
      nix
      bash
      coreutils
      systemd
    ];

    # Override fastfetch config with SuperClaude Framework compliance and dynamic system pattern
    home.file.".config/fastfetch/config.jsonc" = mkForce {
      text = ''
        {
          "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/json_schema.json",
          "logo": {
            "source": "none"
          },
          "display": {
            "separator": " "
          },
          "modules": [
            {
              "type": "chassis",
              "key": "(◕‿◕)",
              "format": "GPD-P3",
              "keyColor": "cyan"
            },
            {
              "type": "os",
              "key": "ヽ(°▽°)ノ",
              "format": "{2}",
              "keyColor": "blue"
            },
            {
              "type": "memory",
              "key": "(｡◕‿◕｡)",
              "format": "{percentage}%",
              "keyColor": "green"
            },
            {
              "type": "display",
              "key": "(＾◡＾)",
              "format": "{count}📺",
              "keyColor": "magenta"
            },
            {
              "type": "uptime",
              "key": "(´∀`)",
              "format": "{compactHours}h{compactMinutes}m",
              "keyColor": "yellow"
            },
            {
              "type": "cpu",
              "key": "( ͡° ͜ʖ ͡°)",
              "format": "{1}",
              "keyColor": "red"
            },
            {
              "type": "command",
              "key": "(づ｡◕‿‿◕｡)づ",
              "text": "${pkgs.nix}/bin/nix-shell -p 'nix bash procps hyprland' --run 'echo \"Touch: \"$(pgrep Hyprland >/dev/null && echo \"(◕‿◕)✓\" || echo \"(╥﹏╥)✗\")'",
              "keyColor": "green"
            },
            {
              "type": "command",
              "key": "♪(´▽｀)",
              "text": "${pkgs.nix}/bin/nix-shell -p 'nix bash procps' --run 'echo \"DJ: \"$(pgrep -f \"dj-mixer\\|supercollider\" >/dev/null && echo \"(☆▽☆)♪\" || echo \"(￣▽￣)zzz\")'",
              "keyColor": "magenta"
            },
            {
              "type": "command",
              "key": "＼(^o^)／",
              "text": "${pkgs.nix}/bin/nix-shell -p 'nix bash procps pipewire' --run 'echo \"Audio: \"$(pgrep pipewire >/dev/null && echo \"(ﾉ◕ヮ◕)ﾉ*:･ﾟ✧\" || echo \"(｡•́︿•̀｡)\")'",
              "keyColor": "blue"
            },
            {
              "type": "command",
              "key": "(ﾉ◕ヮ◕)ﾉ*:･ﾟ✧",
              "text": "${pkgs.nix}/bin/nix-shell -p 'nix bash procps' --run 'echo \"Claude: \"$(pgrep -f claude-code >/dev/null && echo \"(◕‿◕)♡\" || echo \"(´｡• ω •｡`)♡\")'",
              "keyColor": "cyan"
            },
            {
              "type": "command",
              "key": "🚀(◕‿◕)🚀",
              "text": "${pkgs.nix}/bin/nix-shell -p 'nix bash systemd' --run 'echo \"Reboot-Safe: \"$(systemctl --user is-active superclaude-fastfetch >/dev/null 2>&1 && echo \"(◕‿◕)✓\" || echo \"(´･ω･`)\")'",
              "keyColor": "yellow"
            }
          ]
        }
      '';
    };

    # Create SuperClaude fastfetch wrapper with dynamic system pattern
    home.file.".local/bin/superclaude-fetch" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        # Dynamic system variable pattern for tool availability
        sys="nix bash coreutils systemd fastfetch"

        # Execute fastfetch with dynamic shell environment
        ${pkgs.nix}/bin/nix-shell -p $sys --run 'fastfetch --config ~/.config/fastfetch/config.jsonc'
      '';
    };
  };
}