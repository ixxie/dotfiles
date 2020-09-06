{ config, pkgs, ... }:

{
  services = {
    xserver = {
      windowManager = {
        xmonad = {
          enable = true;
          enableContribAndExtras = true;
          config = ''
            import XMonad

            main = do
              xmonad $ defaultConfig
                { modMask = mod4Mask     -- Rebind Mod to the Windows key
                }
          '';
        };
      };
    };
    picom.enable = true;
  };
}
