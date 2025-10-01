{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.hardware.acpiFixes;
in
{
  options.custom.system.hardware.acpiFixes = {
    enable = mkEnableOption "ACPI BIOS error fixes and suppression for GPD Pocket 3";

    suppressErrors = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Suppress cosmetic ACPI BIOS error messages from kernel logs.
        These errors are typically harmless firmware bugs that don't affect functionality.
      '';
    };

    logLevel = mkOption {
      type = types.int;
      default = 4;
      description = ''
        Kernel log level for ACPI messages (0-7).
        4 = warnings and above (recommended to reduce noise from AE_NOT_FOUND errors)
        6 = info and above (more verbose)
        7 = debug (very verbose)
      '';
    };
  };

  config = mkIf cfg.enable {
    # Kernel parameters to reduce ACPI error verbosity
    boot.kernelParams = mkIf cfg.suppressErrors [
      # Reduce ACPI debug output to minimize cosmetic error messages
      "acpi.debug_layer=0x00000000"
      "acpi.debug_level=0x00000000"

      # Set log level to reduce kernel message verbosity
      # This helps suppress AE_NOT_FOUND errors which are typically harmless
      "loglevel=${toString cfg.logLevel}"
    ];

    # Documentation about the ACPI errors
    system.activationScripts.acpiErrorsInfo = ''
      echo ""
      echo "🔧 ACPI Error Suppression Active for GPD Pocket 3"
      echo "   Known Cosmetic Errors (Harmless):"
      echo "   • _SB.PC00.I2C0.TPD0 / TPL1 - Touchpad/Touchscreen ACPI stubs"
      echo "   • _SB.UBTC.RUCC - USB Type-C ACPI reference (firmware bug)"
      echo "   • _SB.PC00.LPCB.HEC.SEN4 - Embedded Controller sensor reference"
      echo "   Status: Errors suppressed via kernel parameters"
      echo "   Impact: None - Hardware functions normally despite BIOS bugs"
      echo ""
    '';

    # Create systemd service to monitor and log actual ACPI issues
    # (distinguishes between cosmetic errors and real problems)
    systemd.services.acpi-error-monitor = {
      description = "Monitor for critical ACPI errors (non-cosmetic)";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "acpi-error-check" ''
          # Check for critical ACPI errors that might indicate real problems
          # (not the cosmetic AE_NOT_FOUND errors)

          CRITICAL_ERRORS=$(journalctl -b -p err | grep -i "acpi" | \
            grep -v "AE_NOT_FOUND" | \
            grep -v "Could not resolve symbol" | \
            grep -v "No support for _PRR" || true)

          if [ -n "$CRITICAL_ERRORS" ]; then
            echo "⚠️  Critical ACPI errors detected (not cosmetic):"
            echo "$CRITICAL_ERRORS"
          else
            echo "✅ No critical ACPI errors detected"
          fi
        '';
      };
    };
  };
}
