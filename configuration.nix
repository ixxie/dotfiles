
{ config, pkgs, ... }: 

{

    # The NixOS release
	system.stateVersion = "16.09";

    # Allow proprietary packages & enable all firmware.
    nixpkgs.config.allowUnfree = true;
    hardware.enableAllFirmware = true;

    # Include the following modules:
    imports =
    [
        ./hardware-configuration.nix
        ./modules/fluxdev.nix
        ./modules/fluxscript.nix
        ./modules/fluxbase.nix
        ./modules/gnome.nix
        ./modules/i18n.nix
        ./modules/efiboot.nix
    ];

    # Enter hostname (network name for the machine configuration).
    networking.hostName = "meso"; 

    # Set your time zone.
    time.timeZone = "Europe/Helsinki";

    # Enter keyboard layout
    services.xserver.layout = "altgr-intl";

    # Define user accounts*. 
    users.extraUsers = 
    { 
        ixxie = 
        {
            home = "/home/ixxie";
            extraGroups = [ "wheel" "networkmanager" ];
            isNormalUser = true;
            uid = 1000;
        };
    };
    # * Password is set using the ‘passwd <username>’ command. 
    

    # Custom configuration options:

    services.xserver.libinput.buttonMapping = "1 1 3 4 5 6 7 8 9";


    # Options to help with Troubleshooting:

    # Enable wireless support via wpa_supplicant.
    # networking.wireless.enable = true;  
    
}
