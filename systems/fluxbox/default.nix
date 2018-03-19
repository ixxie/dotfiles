{ config, pkgs, ... }: 


{

    # Enter hostname (network name for the machine configuration).
    networking.hostName = "fluxbox"; 

    # Set your time zone.
    time.timeZone = "Europe/Amsterdam";

    
    imports =
        [
            ./hardware-config.nix
            ./networking.nix
        ];


}
