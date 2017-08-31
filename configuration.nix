{ config, pkgs, ... }: 


{
    # The NixOS release
	system.stateVersion = "17.03";

    hardware.enableAllFirmware = true;


    # Include the following configuration modules:
    imports =
        [
            ./hardware-configuration.nix
            ./modules/flux.nix
            ./modules/base.nix
            ./modules/dev.nix
            ./modules/pub.nix
            ./modules/sci.nix
            ./modules/gnome.nix
            ./modules/efiboot.nix
            ./modules/unstable.nix
            #./modules/streams.nix
        ];


    boot.kernelModules = 
        [
            "kmv-intel"
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
    environment.variables =
        {
            FLUX_HOME = [ "/home/ixxie/Documents/fluxstack" ];

            SCRIPT_DIR = [ "/home/ixxie/Documents/scripts" ];
        };


    ####################
    # Network Settings #
    ####################

    programs.ssh.knownHosts = 
        [
            {
                hostNames = [ "fluxstack" "188.166.0.19" ];
                publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCmMzxUATmHkuN8GUxdNCExhxyZmZjqHpCCAgc8MCeKVj6wiB9GsVxj7E6esw27c7nS1Um1uqbxeddjqszkc72aBxBI2uE5iuUIj6ekpP0R6ELvNn9zIOkE3CVuxZa8EMvvVZwWWTeuMOSwMdpux5WVX8fXLk/XVugc3LOZzG9S9JEZnXDIwBIMz+6fdtwTkKRfmyT6/6Cf3jDesDfJNdnki6xB4tjMEkm1fD7LTUkI6NL8M97TgJnrf5z7TuvEWOeZOeEPWm5mX41w3xG7lHGUxAE1sluH6WLRwOrqFvWCuL9pUj/88Zc6QR/rtUebnpDn5JgLJOXG9PEKEs3GBe8N+BiBMWBTFtPhGwGpFcQvFenuzV0Kii/VgVbGPTDLG+wmpDVku0XLkh/0/d6/bu24FmIQyyfVZLmwPQ/CiuECWevVIeu0nW8sRs4TC5ziiXBtSIbkjA1i+GnkJpGqr/r2P7YAPP6/kfDhSoGdnBWX4s5MtyzWB5u05hqamkVZs95Xgs9mhrkFiUNAaiGKqU9fNCvxJemZfQGwrpQpWAIZQ6SBbL8p7nf9Gn5bhdUPNbTk/8C1uQZDmilXnxuLdjogiwyL0zeK4zwuiHPeDqdJy3+xTjyehVYciqJrGxGeZUPgsmNU55VAyEm+tHsczio9NSi4/HF0breQ+Gm45Z1NVw==";
            }
        ];


    ###################
    # Custom Settings #
    ###################

    # Mouse Button Mapping (maps middle to left button)
    services.xserver.libinput.buttonMapping = "1 1 3 4 5 6 7 8 9";

    # Removes psmouse error on boot
    boot.blacklistedKernelModules = [ "psmouse" ];
}
