{ config, pkgs, lib, ... }: 

with lib;
{ 

  options =
  {
    desktop = mkOption
    {
      type = types.string;
      default = "none";
      description = "Sets the desktop environment; set to: none or gnome.";
    };
  };
    
  config = mkIf (config.desktop == "gnome")
  {
    environment =
    {
      systemPackages = 
  		with pkgs; 
  		[
        chrome-gnome-shell
        evince
        firefox
        gnome3.gdm
        gparted
        google-chrome
        gimp
        numix-gtk-theme
        numix-icon-theme-circle
        skype
        transmission_gtk
        vlc
        vscode
        simple-scan
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
          displayManager.gdm =
          {
            enable = true;
          };
  
          # Enable the Gnome Desktop Environment
          desktopManager.gnome3.enable = true;
  
      };

      # Enable CUPS to print documents.
      printing.enable = true;
    };
  
    fonts = 
    {
      fonts = 
      with pkgs; 
      [ 
        source-code-pro
      ];
    };
  };
}
