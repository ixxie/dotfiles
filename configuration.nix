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
        ./modules/fluxbase.nix
        ./modules/fluxdev.nix
        ./modules/fluxscript.nix
        ./modules/gnome.nix
        ./modules/efiboot.nix
    ];

    #####################
    # Personal Settings #
    #####################

    # Enter hostname (network name for the machine configuration).
    networking.hostName = "meso"; 

    # Set your time zone.
    time.timeZone = "Europe/Helsinki";

	# Use ZSH for default shell.
	users.defaultUserShell = "/var/run/current-system/sw/bin/zsh";

    # Enter keyboard layout
    services.xserver.layout = "us";
    services.xserver.xkbVariant = "altgr-intl";

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
    
    # Set path for flux
    environment.variables.FLUX_HOME = [ "/home/ixxie/Fluxstack" ];


    ###################
    # Custom Settings #
    ###################

    # Mouse Button Mapping (maps middle to left button)
    services.xserver.libinput.buttonMapping = "1 1 3 4 5 6 7 8 9";

    # Enable gnome GDM
    services.xserver.displayManager.gdm.enable = true;


    # Options to help with Troubleshooting:

    # Enable wireless support via wpa_supplicant.
    # networking.wireless.enable = true;  
    
    # Select internationalisation properties.
    # i18n = 
    # {
    #   consoleFont = "Lat2-Terminus16";
    #   consoleKeyMap = "us";
    #   defaultLocale = "en_US.UTF-8";
    # };
    #

}
