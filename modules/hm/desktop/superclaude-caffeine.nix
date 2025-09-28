{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.hm.desktop.superclaudeCaffeine;
in
{
  options.custom.hm.desktop.superclaudeCaffeine = {
    enable = mkEnableOption "SuperClaude Framework caffeine mode for uninterrupted AI operations";

    agentOperations = mkOption {
      type = types.bool;
      default = true;
      description = "Prevent sleep during agent automation operations";
    };

    distributedSessions = mkOption {
      type = types.bool;
      default = true;
      description = "Maintain wake state during distributed workstation coordination";
    };

    stressTesting = mkOption {
      type = types.bool;
      default = true;
      description = "Override all power management during stress testing";
    };
  };

  config = mkIf cfg.enable {
    # Caffeine script for SuperClaude operations - REBOOT-SAFE
    home.packages = [
      # Main caffeine control script
      (pkgs.writeShellScriptBin "superclaude-caffeine" ''
        #!/usr/bin/env bash
        # REBOOT-SAFE: Dynamic system variable pattern for tool availability

        sys="bash systemd procps coreutils"

        OPERATION="$1"
        DURATION="''${2:-3600}"  # Default 1 hour
        CAFFEINE_PID_FILE="/tmp/superclaude-caffeine.pid"

        case "$OPERATION" in
            "start"|"on")
                echo "☕ Starting SuperClaude caffeine mode..."

                # Inhibit sleep/suspend/idle
                nix-shell -p $sys --run "systemd-inhibit \
                    --what=sleep:suspend:idle:handle-power-key:handle-suspend-key:handle-hibernate-key \
                    --who='SuperClaude Framework' \
                    --why='AI agent operations in progress' \
                    --mode=block \
                    sleep '$DURATION'" &

                echo $! > "$CAFFEINE_PID_FILE"
                echo "✅ Caffeine active (PID: $(cat $CAFFEINE_PID_FILE)) for ''${DURATION}s"
                echo "🤖 System will stay awake during SuperClaude operations"
                ;;

            "stop"|"off")
                echo "🛑 Stopping SuperClaude caffeine mode..."

                if [ -f "$CAFFEINE_PID_FILE" ]; then
                    CAFFEINE_PID=$(cat "$CAFFEINE_PID_FILE")
                    if nix-shell -p $sys --run "kill -0 '$CAFFEINE_PID' 2>/dev/null"; then
                        nix-shell -p $sys --run "kill '$CAFFEINE_PID'"
                        echo "✅ Caffeine stopped (PID: $CAFFEINE_PID)"
                    else
                        echo "⚠️ Caffeine process not running"
                    fi
                    nix-shell -p $sys --run "rm -f '$CAFFEINE_PID_FILE'"
                else
                    echo "ℹ️ No active caffeine session found"
                fi

                # Also stop any systemd-inhibit processes related to SuperClaude
                nix-shell -p $sys --run "pkill -f 'SuperClaude Framework' || true"
                ;;

            "status")
                echo "☕ SuperClaude Caffeine Status"
                echo "============================"

                if [ -f "$CAFFEINE_PID_FILE" ] && nix-shell -p $sys --run "kill -0 \"\$(cat '$CAFFEINE_PID_FILE')\" 2>/dev/null"; then
                    echo "🟢 Status: ACTIVE"
                    echo "📱 PID: $(cat $CAFFEINE_PID_FILE)"

                    # Show active inhibitors
                    echo ""
                    echo "🔒 Active Power Inhibitors:"
                    nix-shell -p $sys --run "systemd-inhibit --list | grep -A10 -B2 'SuperClaude' || echo '  None found via systemd-inhibit'"
                else
                    echo "🔴 Status: INACTIVE"
                    nix-shell -p $sys --run "rm -f '$CAFFEINE_PID_FILE' 2>/dev/null || true"
                fi

                # Show current power settings
                echo ""
                echo "⚡ Current Power Management:"
                if nix-shell -p hyprland --run "command -v hyprctl >/dev/null"; then
                    echo "  Hyprland DPMS: $(nix-shell -p hyprland --run "hyprctl getoption misc:disable_hyprland_logo | grep -o 'int: [0-1]' | cut -d' ' -f2")"
                fi
                ;;

            "agent")
                echo "🤖 Starting agent-specific caffeine mode..."
                # Extended duration for agent operations (2 hours default)
                superclaude-caffeine start ''${2:-7200}
                ;;

            "stress-test")
                echo "🔥 Starting stress test caffeine mode..."
                # Maximum duration for stress testing (4 hours)
                superclaude-caffeine start ''${2:-14400}
                ;;

            "distributed")
                echo "🌐 Starting distributed session caffeine mode..."
                # Long duration for distributed operations (6 hours)
                superclaude-caffeine start ''${2:-21600}
                ;;

            *)
                echo "☕ SuperClaude Framework Caffeine Control"
                echo "========================================"
                echo ""
                echo "Usage: superclaude-caffeine <command> [duration]"
                echo ""
                echo "Commands:"
                echo "  start|on [seconds]     - Start caffeine mode (default: 1 hour)"
                echo "  stop|off              - Stop caffeine mode"
                echo "  status                - Show current caffeine status"
                echo "  agent [seconds]       - Start for agent operations (default: 2 hours)"
                echo "  stress-test [seconds] - Start for stress testing (default: 4 hours)"
                echo "  distributed [seconds] - Start for distributed ops (default: 6 hours)"
                echo ""
                echo "Examples:"
                echo "  superclaude-caffeine agent              # 2 hour caffeine for agents"
                echo "  superclaude-caffeine start 1800         # 30 minute caffeine"
                echo "  superclaude-caffeine stress-test        # 4 hour stress test mode"
                echo "  superclaude-caffeine status             # Check current status"
                ;;
        esac
      '')

      # Automatic caffeine activation for specific processes - REBOOT-SAFE
      (pkgs.writeShellScriptBin "superclaude-auto-caffeine" ''
        #!/usr/bin/env bash
        # REBOOT-SAFE: Dynamic system variable pattern

        sys="bash procps coreutils gnugrep"

        # Monitor for SuperClaude processes and auto-activate caffeine
        while true; do
            # Check for active SuperClaude processes
            CLAUDE_PROCESSES=$(nix-shell -p $sys --run "ps aux | grep -E '(claude-code|api-workstation-coordinator|stress-test-coordinator)' | grep -v grep | wc -l")
            CAFFEINE_ACTIVE=$(superclaude-caffeine status | nix-shell -p $sys --run "grep -q 'ACTIVE'" && echo "1" || echo "0")

            if [ "$CLAUDE_PROCESSES" -gt 0 ] && [ "$CAFFEINE_ACTIVE" = "0" ]; then
                echo "🤖 SuperClaude processes detected, activating caffeine..."
                superclaude-caffeine agent
            elif [ "$CLAUDE_PROCESSES" = "0" ] && [ "$CAFFEINE_ACTIVE" = "1" ]; then
                echo "🛑 No SuperClaude processes, deactivating caffeine..."
                superclaude-caffeine stop
            fi

            nix-shell -p $sys --run "sleep 30"  # Check every 30 seconds
        done
      '')

      # Quick caffeine toggle for Hyprland - REBOOT-SAFE
      (pkgs.writeShellScriptBin "caffeine-toggle" ''
        #!/usr/bin/env bash
        # REBOOT-SAFE: Dynamic system variable pattern

        sys="bash gnugrep libnotify"

        STATUS=$(superclaude-caffeine status | nix-shell -p $sys --run "grep -q 'ACTIVE'" && echo "ACTIVE" || echo "INACTIVE")

        if [ "$STATUS" = "ACTIVE" ]; then
            superclaude-caffeine stop
            nix-shell -p $sys --run "notify-send -a 'SuperClaude' '☕ Caffeine OFF' 'System can sleep normally' -t 2000" || true
        else
            superclaude-caffeine start 3600  # 1 hour default
            nix-shell -p $sys --run "notify-send -a 'SuperClaude' '☕ Caffeine ON' 'System will stay awake' -t 2000" || true
        fi
      '')
    ];

    # Systemd user service for auto-caffeine monitoring - REBOOT-SAFE
    systemd.user.services.superclaude-auto-caffeine = mkIf cfg.agentOperations {
      Unit = {
        Description = "SuperClaude Framework automatic caffeine management";
        After = [ "hyprland-session.target" ];
        PartOf = [ "hyprland-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart = pkgs.writeShellScript "superclaude-auto-caffeine-start" ''
          #!/usr/bin/env bash
          # REBOOT-SAFE: Dynamic system variable pattern
          sys="bash"
          nix-shell -p $sys --run 'superclaude-auto-caffeine'
        '';
        Restart = "always";
        RestartSec = "10";

        # REBOOT-SAFE: Resource limits and environment
        MemoryMax = "256M";
        CPUQuota = "30%";
        Environment = [
          "TERM=xterm-256color"
          "WAYLAND_DISPLAY=wayland-1"
        ];
      };

      Install = {
        WantedBy = [ "hyprland-session.target" ];
      };
    };

    # Enhanced power management integration
    home.file.".config/superclaude/power-profile.conf".text = ''
      # SuperClaude Framework Power Management Profile

      [General]
      # Automatic caffeine activation
      auto_caffeine=${if cfg.agentOperations then "true" else "false"}

      # Default durations (seconds)
      agent_duration=7200        # 2 hours
      stress_test_duration=14400 # 4 hours
      distributed_duration=21600 # 6 hours

      [Inhibitors]
      # What to inhibit during operations
      sleep=true
      suspend=true
      idle=true
      handle_power_key=true
      handle_suspend_key=true
      handle_hibernate_key=true

      [Notifications]
      # Show notifications for caffeine state changes
      notify_on_start=true
      notify_on_stop=true
      notify_duration=2000
    '';

    # Hyprland keybinding for quick caffeine toggle
    wayland.windowManager.hyprland.settings = mkIf config.wayland.windowManager.hyprland.enable {
      bind = [
        # SuperClaude caffeine controls
        "SUPER_SHIFT, C, exec, caffeine-toggle"
        "SUPER_SHIFT, A, exec, superclaude-caffeine agent"
        "SUPER_SHIFT, S, exec, superclaude-caffeine stress-test"
        "SUPER_SHIFT, D, exec, superclaude-caffeine distributed"
      ];
    };

    # Integration with existing power management - REBOOT-SAFE
    home.activation.superclaudeCaffeineSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # REBOOT-SAFE: Dynamic system variable pattern
      sys="bash coreutils"

      echo "Setting up SuperClaude caffeine integration..."

      # Create caffeine status directory
      ${pkgs.writeShellScript "caffeine-setup" ''
        #!/usr/bin/env bash
        sys="bash coreutils"
        nix-shell -p $sys --run "mkdir -p $HOME/.local/share/superclaude/caffeine"

        # Create default configuration if it doesn't exist
        if ! nix-shell -p $sys --run "test -f $HOME/.config/superclaude/power-profile.conf"; then
          nix-shell -p $sys --run "mkdir -p $HOME/.config/superclaude"
          echo "✅ SuperClaude caffeine configuration initialized"
        fi

        echo "☕ SuperClaude caffeine management ready"
        echo "   - superclaude-caffeine: Manual control"
        echo "   - caffeine-toggle: Quick Hyprland toggle (Super+Shift+C)"
        echo "   - Auto-monitoring: ${if cfg.agentOperations then "ENABLED" else "DISABLED"}"
      ''}
    '';
  };
}