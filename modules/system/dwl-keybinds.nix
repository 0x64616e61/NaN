{ config, pkgs, lib, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      dwl = prev.dwl.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          # Change MODKEY from Alt to SUPER (Logo key)
          sed -i 's/#define MODKEY WLR_MODIFIER_ALT/#define MODKEY WLR_MODIFIER_LOGO/' config.def.h

          # Change terminal from foot to ghostty
          sed -i 's|"foot"|"${pkgs.ghostty}/bin/ghostty"|' config.def.h

          # Keep default keybind structure but with SUPER key
        '';
      });
    })
  ];
}
