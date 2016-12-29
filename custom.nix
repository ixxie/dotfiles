{ pkgs, ... }: { 

# Personal Configuration File
# Name: Matan Bendix Shenhav

    networking = {
        # Define your hostname.
        hostName = "meso"; 
    
        # Enable wireless support via wpa_supplicant.
        # networking.wireless.enable = true;  
    };

    # Select internationalisation properties.
    # i18n = {
    #   consoleFont = "Lat2-Terminus16";
    #   consoleKeyMap = "us";
    #   defaultLocale = "en_US.UTF-8";
    # };

    # Set your time zone.
    time.timeZone = "Europe/Helsinki";

    # Define user accounts. Don't forget to set a rd with ‘passwd’.
    users = {
        extraUsers = { 
            ixxie = {
                home = "/home/ixxie";
                extraGroups = [ "wheel" "networkmanager" ];
                isNormalUser = true;
                uid = 1000;
            };
        };
    };

}