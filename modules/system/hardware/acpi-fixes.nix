{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.hardware.acpiFixes;

  # Compile ACPI override SSDT table
  acpiOverride = pkgs.stdenv.mkDerivation {
    name = "acpi-override";
    src = ./acpi-override.asl;
    nativeBuildInputs = [ pkgs.acpica-tools ];

    unpackPhase = "true";

    buildPhase = ''
      iasl -tc ${./acpi-override.asl}
    '';

    installPhase = ''
      mkdir -p $out/kernel/firmware/acpi
      cp acpi-override.aml $out/kernel/firmware/acpi/
    '';
  };
in
{
  options.custom.system.hardware.acpiFixes = {
    enable = mkEnableOption "ACPI BIOS error fixes for GPD Pocket 3";

    useOverride = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Use ACPI DSDT override to patch missing BIOS symbols.
        This creates stub devices/methods for:
        - _SB.PC00.I2C0.TPD0/TPL1 (touchpad stubs)
        - _SB.UBTC.RUCC (USB Type-C method)
        - _SB.PC00.LPCB.HEC.SEN4 (EC sensor)
      '';
    };
  };

  config = mkIf cfg.enable {
    # Install ACPI override table to fix missing symbols
    hardware.firmware = mkIf cfg.useOverride [ acpiOverride ];

    # Kernel parameters for ACPI override loading
    boot.kernelParams = mkIf cfg.useOverride [
      # Enable custom ACPI tables from initrd
      "acpi_enforce_resources=lax"
    ];

    # Enable early ACPI table loading
    boot.initrd.prepend = mkIf cfg.useOverride [
      "${acpiOverride}/kernel/firmware/acpi/acpi-override.aml"
    ];

    # Documentation about the ACPI fixes
    system.activationScripts.acpiFixesInfo = ''
      echo ""
      echo "🔧 ACPI DSDT Override Active for GPD Pocket 3"
      echo "   Fixed Missing BIOS Symbols:"
      echo "   • _SB.PC00.I2C0.TPD0 / TPL1 - Touchpad/Touchscreen device stubs"
      echo "   • _SB.UBTC.RUCC - USB Type-C UCSI method stub"
      echo "   • _SB.PC00.LPCB.HEC.SEN4 - Embedded Controller sensor stub"
      echo "   Status: ACPI errors should be eliminated"
      echo "   Method: SSDT override table loaded at boot"
      echo ""
    '';

    # Monitor for remaining ACPI issues
    systemd.services.acpi-error-monitor = {
      description = "Monitor for ACPI errors after fixes applied";
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = pkgs.writeShellScript "acpi-error-check" ''
          # Check if ACPI errors still present after fixes
          ACPI_ERRORS=$(journalctl -b -p err | grep -i "ACPI.*Error" || true)

          if [ -n "$ACPI_ERRORS" ]; then
            echo "⚠️  Remaining ACPI errors detected:"
            echo "$ACPI_ERRORS"
            echo ""
            echo "Please report these to GPD Pocket 3 NixOS configuration maintainer"
          else
            echo "✅ No ACPI errors detected - all fixes successful"
          fi
        '';
      };
    };
  };
}
