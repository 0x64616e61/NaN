{ config, lib, pkgs, ... }:

{
  # Ensure workflows.conf is always symlinked to our Ghostty config
  system.activationScripts.workflowsSymlink = ''
    if [ -f /home/a/.config/hypr/workflows.conf ] && [ ! -L /home/a/.config/hypr/workflows.conf ]; then
      rm -f /home/a/.config/hypr/workflows.conf
    fi
    ln -sf /nix-modules/configs/workflows-ghostty.conf /home/a/.config/hypr/workflows.conf
  '';
}