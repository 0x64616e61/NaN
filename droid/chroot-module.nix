{ config, lib, pkgs, ... }:

with lib;

{
  options.system.chroot = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable chroot mode instead of proot";
    };
  };

  config = mkIf config.system.chroot.enable {
    # Override the login script to use chroot instead of proot
    environment.packages = with pkgs; [
      (writeScriptBin "chroot-login" ''
        #!/system/bin/sh
        # Chroot-based login for Nix-on-Droid
        set -eu

        export USER="nix-on-droid"
        export HOME="/data/data/com.termux.nix/files/home"
        export PATH="/nix/var/nix/profiles/default/bin:$PATH"

        # Check if running as root
        if [ "$(id -u)" != "0" ]; then
          echo "Attempting to get root access..."
          # Try to find su
          for su_path in /system/bin/su /sbin/su /system/xbin/su /data/adb/magisk/su; do
            if [ -x "$su_path" ]; then
              echo "Found su at $su_path"
              exec $su_path -c "$0 $@"
            fi
          done
          echo "Error: Root access required but su not found"
          echo "Falling back to proot mode..."
          exec /data/data/com.termux.nix/files/usr/bin/login.proot "$@"
        fi

        echo "✓ Running with root privileges"

        CHROOT_PATH=/data/data/com.termux.nix/files/chroot
        FILES_USR=/data/data/com.termux.nix/files/usr

        # Setup chroot environment
        mkdir -p $CHROOT_PATH

        # Mount necessary directories
        for dir in /proc /sys /dev /dev/pts /system /storage /data; do
          mkdir -p $CHROOT_PATH$dir
          if ! mountpoint -q $CHROOT_PATH$dir 2>/dev/null; then
            mount --rbind $dir $CHROOT_PATH$dir 2>/dev/null || true
          fi
        done

        # Mount Nix-on-Droid directories
        for dir in nix bin etc tmp usr home; do
          mkdir -p $CHROOT_PATH/$dir
          if ! mountpoint -q $CHROOT_PATH/$dir 2>/dev/null; then
            mount --rbind $FILES_USR/$dir $CHROOT_PATH/$dir 2>/dev/null || true
          fi
        done

        echo "Entering chroot environment..."
        exec chroot $CHROOT_PATH /usr/bin/env \
          HOME=/home \
          USER=root \
          PATH="/nix/var/nix/profiles/default/bin:/usr/bin:/bin" \
          SHELL=/nix/var/nix/profiles/default/bin/bash \
          /nix/var/nix/profiles/default/bin/bash --login
      '')

      (writeScriptBin "switch-to-chroot" ''
        #!${pkgs.bash}/bin/bash
        echo "Switching Nix-on-Droid to chroot mode..."

        # Backup current login
        if [ ! -f /data/data/com.termux.nix/files/usr/bin/login.proot ]; then
          cp /data/data/com.termux.nix/files/usr/bin/login \
             /data/data/com.termux.nix/files/usr/bin/login.proot
        fi

        # Replace with chroot login
        cp ${pkgs.writeScript "login" ''
          #!/system/bin/sh
          exec ${config.environment.packages}/bin/chroot-login "$@"
        ''} /data/data/com.termux.nix/files/usr/bin/login

        chmod 755 /data/data/com.termux.nix/files/usr/bin/login
        echo "✓ Chroot mode enabled. Restart the app to use it."
      '')

      (writeScriptBin "switch-to-proot" ''
        #!${pkgs.bash}/bin/bash
        echo "Switching back to proot mode..."

        if [ -f /data/data/com.termux.nix/files/usr/bin/login.proot ]; then
          mv /data/data/com.termux.nix/files/usr/bin/login.proot \
             /data/data/com.termux.nix/files/usr/bin/login
          echo "✓ Proot mode restored. Restart the app."
        else
          echo "Error: Proot backup not found"
        fi
      '')
    ];
  };
}