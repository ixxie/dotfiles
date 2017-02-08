{ pkgs, ... }: 

{ 
    services = 
    {
        # Enable the X11 windowing system
        xserver = 
        {
            enable = true;
            xkbOptions = "eurosign:e";


            # Enable the Gnome Display Manager
            displayManager.gdm.enable = true;

            # Enable the Gnome Desktop Environment
            desktopManager = 
            {
                gnome3 = 
                {
                    enable = true;
                }; 
            };
        };
    };

}