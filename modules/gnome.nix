{ pkgs, ... }: 

{ 
    services = 
    {
        # Enable the X11 windowing system.
        xserver = 
        {
            enable = true;
            xkbOptions = "eurosign:e";

            # Enable the Gnome Desktop Environment.

            #displayManager.gdm.enable = true;

            desktopManager = 
            {
                gnome3 = 
                {
                    enable = true;
                }; 
            };
        };
    };


	environment = 
	{
		systemPackages = 
			with pkgs; 
            [
                gnome3.gnome-shell-extensions
			]; 
	};

}