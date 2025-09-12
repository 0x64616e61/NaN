{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.custom.system.services.unifiedRemote;
  
  # Download and extract Unified Remote from deb package
  urserver = pkgs.stdenv.mkDerivation rec {
    pname = "unified-remote-server";
    version = "3.14.0";
    
    src = pkgs.fetchurl {
      url = "https://www.unifiedremote.com/download/linux-x64-deb";
      sha256 = "0vygxwz2d9xrq51xa29nhzgvb2ws1bgmrk3fn1p8zkqykpkficrv";
      name = "urserver.deb";
    };
    
    nativeBuildInputs = with pkgs; [ 
      autoPatchelfHook 
      dpkg
    ];
    
    buildInputs = with pkgs; [
      stdenv.cc.cc.lib
      openssl
      zlib
      libusb1
      bluez
      xorg.libX11
      xorg.libXtst
      xorg.libXi
      xorg.libXext
      avahi
    ];
    
    unpackPhase = ''
      dpkg-deb -x $src .
    '';
    
    installPhase = ''
      # Copy the extracted files
      mkdir -p $out
      cp -r opt/urserver/* $out/
      
      # Create wrapper scripts
      mkdir -p $out/bin
      
      cat > $out/bin/urserver-start <<EOF
      #!/bin/sh
      export LD_LIBRARY_PATH="${lib.makeLibraryPath buildInputs}:\$LD_LIBRARY_PATH"
      cd $out
      exec $out/urserver --daemon
      EOF
      
      cat > $out/bin/urserver-stop <<EOF
      #!/bin/sh
      pkill -f urserver || true
      EOF
      
      chmod +x $out/bin/urserver-start
      chmod +x $out/bin/urserver-stop
      chmod +x $out/urserver 2>/dev/null || true
    '';
  };
in
{
  options.custom.system.services.unifiedRemote = {
    enable = mkEnableOption "Unified Remote server for controlling PC from mobile devices";
    
    port = mkOption {
      type = types.int;
      default = 9512;
      description = "Port for Unified Remote web interface";
    };
    
    openFirewall = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to open firewall ports for Unified Remote";
    };
    
    autoStart = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to start Unified Remote server on boot";
    };
  };

  config = mkIf cfg.enable {
    # Install the package
    environment.systemPackages = [ urserver ];
    
    # Create systemd service
    systemd.services.unified-remote = {
      description = "Unified Remote Server";
      after = [ "network.target" ];
      wantedBy = mkIf cfg.autoStart [ "multi-user.target" ];
      
      serviceConfig = {
        Type = "forking";
        User = "root";
        Group = "root";
        ExecStart = "${urserver}/bin/urserver-start";
        ExecStop = "${urserver}/bin/urserver-stop";
        Restart = "on-failure";
        RestartSec = 5;
        
        # Environment variables
        Environment = [
          "HOME=/var/lib/unified-remote"
          "OPENSSL_CONF=/etc/ssl/"
        ];
        
        # Create state directory
        StateDirectory = "unified-remote";
        WorkingDirectory = "/var/lib/unified-remote";
      };
      
      preStart = ''
        # Ensure state directory exists with correct permissions
        mkdir -p /var/lib/unified-remote/.urserver
        
        # Create default configuration if it doesn't exist
        if [ ! -f /var/lib/unified-remote/.urserver/urserver.config ]; then
          cat > /var/lib/unified-remote/.urserver/urserver.config <<EOF
        {
          "network": {
            "port": ${toString cfg.port},
            "port_http": ${toString (cfg.port + 1)}
          },
          "security": {
            "enable_password": false
          }
        }
        EOF
        fi
      '';
    };
    
    # Open firewall ports if requested
    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ 
        cfg.port           # Main server port
        (cfg.port + 1)     # HTTP web interface port
        9510 9511          # Discovery ports
      ];
      allowedUDPPorts = [ 
        9512               # Broadcast port
      ];
    };
    
    # Create user service wrapper for convenience
    environment.shellAliases = {
      "ur-start" = "sudo systemctl start unified-remote";
      "ur-stop" = "sudo systemctl stop unified-remote";
      "ur-restart" = "sudo systemctl restart unified-remote";
      "ur-status" = "sudo systemctl status unified-remote";
      "ur-logs" = "sudo journalctl -u unified-remote -f";
    };
  };
}