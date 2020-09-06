{config, pkgs, fetchurl, ...}:

{
    nixpkgs.overlays = [
      (self: super: {
        xf86_input_wacom = super.xf86_input_wacom.overrideAttrs (old: rec {
          name = "xf86-input-wacom-0.39.0";
          src = super.fetchurl {
            url = "https://github.com/linuxwacom/xf86-input-wacom/archive/${name}.tar.gz";
            sha256 = "1m8gxqjs6302p0r7d4a2k4acvzjiwz1jh6hm7zzwr8mfj4fs2zpl";
          };
          nativeBuildInputs = [ 
            self.xorg.utilmacros 
            self.autoreconfHook 
          ];
        });
      })
    ];

    services.xserver = {
      wacom.enable = true;
      libinput.enable = true;
    };

    environment.systemPackages = with pkgs; [
      wacomtablet
    ];
}