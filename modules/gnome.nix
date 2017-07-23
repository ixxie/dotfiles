{ pkgs, ... }: 

{ 
    
    environment =
    {
        systemPackages = 
			with pkgs; 
			[
				numix-gtk-theme
				numix-icon-theme-circle
            ];

        # GTK3 global theme (widget and icon theme)
        etc."xdg/gtk-3.0/settings.ini" = 
        {
            text = 
                ''
                    [Settings]
                    gtk-icon-theme-name=Numix-circle
                    gtk-theme-name=Numix
                    gtk-application-prefer-dark-theme = true
                '';
        };
    };

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
            desktopManager.gnome3.enable = true;

        };
    };

}