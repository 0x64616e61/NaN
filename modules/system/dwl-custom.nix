{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      dwl = prev.dwl.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          # Change MODKEY from Alt to SUPER (Logo key)
          ${pkgs.gnused}/bin/sed -i 's/#define MODKEY WLR_MODIFIER_ALT/#define MODKEY WLR_MODIFIER_LOGO/' config.def.h

          # Change terminal from foot to foot with full path
          ${pkgs.gnused}/bin/sed -i 's|"foot"|"${pkgs.foot}/bin/foot"|' config.def.h

          # Change menu from bemenu-run to full path (prevents crash)
          ${pkgs.gnused}/bin/sed -i 's|"bemenu-run"|"${pkgs.bemenu}/bin/bemenu-run"|' config.def.h

          echo "[grOSs] DWL configured with SUPER key, foot terminal, and bemenu launcher"
        '';
      });
    })
  ];
}
