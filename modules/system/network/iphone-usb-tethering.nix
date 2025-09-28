{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.network.iphoneUsbTethering;
in
{
  options.custom.system.network.iphoneUsbTethering = {
    enable = mkEnableOption "iPhone USB tethering support";

    autoConnect = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically connect when iPhone is plugged in";
    };

    connectionPriority = mkOption {
      type = types.int;
      default = 10;
      description = "NetworkManager connection priority (higher = preferred)";
    };
  };

  config = mkIf cfg.enable {
    # Required packages for iPhone USB tethering
    environment.systemPackages = with pkgs; [
      libimobiledevice    # iPhone communication tools
      ifuse               # iPhone filesystem mounting
      usbmuxd             # USB multiplexer daemon
    ];

    # Enable usbmuxd service for iPhone communication
    services.usbmuxd = {
      enable = true;
      user = "usbmux";
      group = "usbmux";
    };

    # Create udev rules for iPhone USB detection
    services.udev.extraRules = ''
      # iPhone USB Tethering - Auto-detection and setup
      # Apple vendor ID: 05ac
      SUBSYSTEM=="usb", ATTR{idVendor}=="05ac", ATTR{idProduct}=="12a*", TAG+="systemd", ENV{SYSTEMD_WANTS}="iphone-usb-tethering.service"

      # iPhone ethernet interface (ipheth driver) - trigger NetworkManager
      SUBSYSTEM=="net", ACTION=="add", DRIVERS=="ipheth", TAG+="systemd", ENV{SYSTEMD_WANTS}="NetworkManager.service", RUN+="${pkgs.systemd}/bin/systemctl start iphone-usb-connect@$env{INTERFACE}.service"

      # Set iPhone ethernet interface permissions
      SUBSYSTEM=="net", DRIVERS=="ipheth", GROUP="networkmanager", MODE="0664"
    '';

    # Create systemd service for automatic iPhone USB connection
    systemd.services.iphone-usb-tethering = {
      description = "iPhone USB Tethering Auto-Connect";
      after = [ "network.target" "usbmuxd.service" ];
      wants = [ "usbmuxd.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        Environment = [
          "PATH=${pkgs.libimobiledevice}/bin:${pkgs.networkmanager}/bin:${pkgs.iproute2}/bin:${pkgs.coreutils}/bin"
        ];
        ExecStart = pkgs.writeShellScript "iphone-usb-connect" ''
          set -euo pipefail

          echo "iPhone USB Tethering: Starting connection attempt..."

          # Wait for usbmuxd to be ready
          sleep 2

          # Check if iPhone is available
          if idevice_id --list | grep -q '^[0-9a-f]'; then
            echo "iPhone detected via USB"

            # Wait for ipheth interface to appear
            timeout=30
            while [ $timeout -gt 0 ]; do
              if ip link show | grep -q "enp.*u"; then
                break
              fi
              sleep 1
              ((timeout--))
            done

            if [ $timeout -eq 0 ]; then
              echo "Timeout waiting for iPhone ethernet interface"
              exit 1
            fi

            # Find iPhone ethernet interface
            iphone_iface=$(ip link show | grep -o "enp[0-9]*s[0-9]*u[0-9]*" | head -1)

            if [ -n "$iphone_iface" ]; then
              echo "Found iPhone ethernet interface: $iphone_iface"

              # Create or update NetworkManager connection
              nmcli connection delete "iPhone-USB-Tethering" 2>/dev/null || true
              nmcli connection add type ethernet con-name "iPhone-USB-Tethering" \
                ifname "$iphone_iface" \
                connection.autoconnect yes \
                connection.autoconnect-priority ${toString cfg.connectionPriority} \
                ipv4.method auto \
                ipv6.method auto

              # Activate the connection
              nmcli connection up "iPhone-USB-Tethering" ifname "$iphone_iface"

              echo "iPhone USB tethering activated on $iphone_iface"
            else
              echo "No iPhone ethernet interface found"
              exit 1
            fi
          else
            echo "No iPhone detected via USB"
            exit 1
          fi
        '';
      };
    };

    # Template service for per-interface connection
    systemd.services."iphone-usb-connect@" = {
      description = "iPhone USB Connect for interface %i";
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        Environment = [
          "PATH=${pkgs.networkmanager}/bin:${pkgs.coreutils}/bin"
        ];
        ExecStart = pkgs.writeShellScript "iphone-usb-connect-interface" ''
          set -euo pipefail

          interface="$1"
          echo "Connecting iPhone USB interface: $interface"

          # Wait a moment for interface to be ready
          sleep 1

          # Try to connect via NetworkManager
          nmcli device connect "$interface" 2>/dev/null || {
            echo "Direct connection failed, trying to activate iPhone-USB-Tethering profile"
            nmcli connection up "iPhone-USB-Tethering" ifname "$interface" 2>/dev/null || true
          }
        '';
        ExecStartPost = "${pkgs.coreutils}/bin/echo 'iPhone USB interface $1 connection attempt completed'";
      };
    };

    # NetworkManager configuration for iPhone handling
    networking.networkmanager = {
      enable = mkDefault true;

      # Additional NetworkManager configuration for iPhone
      extraConfig = ''
        [device]
        # Configure iPhone ethernet devices
        match-device=driver:ipheth
        managed=true

        [connection]
        # iPhone connections get medium priority by default
        autoconnect-priority=5
      '';
    };

    # Add user to necessary groups for iPhone access
    users.users = mkIf (config.users.users ? a) {
      a.extraGroups = [ "usbmux" "networkmanager" ];
    };

    # Kernel modules for iPhone ethernet support
    boot.kernelModules = [ "ipheth" ];

    # Firewall configuration - allow iPhone subnet
    networking.firewall = {
      # iPhone typically uses 172.20.10.x subnet
      interfaces."enp+u+" = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 67 68 ];
      };
    };
  };
}