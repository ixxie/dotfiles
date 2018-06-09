{ config, pkgs, lib, ... }: 

# this `with lib` includes the basic library
# into the scope of the body, allowing us to
# use `mkIf` for example, instead of having
# to write `lib.mkIf`

with lib;
{ 

  options =
  {
    # make an option to enable or desable the desktop environment
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
      # add some desktop applications
      systemPackages = 
  		with pkgs; 
  		[
        evince
        firefox
        gnome3.gdm
        gparted
        gimp
        inkscape
        numix-gtk-theme
        numix-icon-theme-circle
        skype
        transmission_gtk
        vlc
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
       # enable the X11 windowing system
       xserver = 
       {
          enable = true;
          xkbOptions = "eurosign:e";
  
          # enable the Gnome Display Manager
          displayManager.gdm =
          {
            enable = true;
          };
  
          # enable the Gnome Desktop Environment
          desktopManager.gnome3.enable = true;
  
      };

      # enable CUPS to print documents.
      printing.enable = true;
    };
  
    fonts = 
    {
      # add some fonts
      fonts = 
      with pkgs; 
      [ 
        source-code-pro
      ];
    };
  };
}
