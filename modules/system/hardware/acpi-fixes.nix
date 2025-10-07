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
      cp ${./acpi-override.asl} acpi-override.asl
      iasl -tc acpi-override.asl
    '';

    installPhase = ''
      mkdir -p $out/lib/firmware/acpi
      cp acpi-override.aml $out/lib/firmware/acpi/
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
    # Kernel parameters to work around BIOS bugs
    boot.kernelParams = [
      # Mask GPE that triggers _QF1 method (reduces HEC.SEN4 errors)
      "acpi_mask_gpe=0x6D"
    ];

    # Documentation about the ACPI fixes - now part of unified system info
    # See modules/system/default.nix for the combined display

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
