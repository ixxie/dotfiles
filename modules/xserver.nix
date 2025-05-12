{ pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
    };
    displayManager.ly.enable = true;
  };

  environment.systemPackages = with pkgs; [
    xfce.tumbler
    xarchiver
    nautilus
  ];
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
  };

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-media-tags-plugin
    ];
  };

  services.printing.enable = true;

  xdg.portal.config = {
    gnome = {
      default = [
        "gnome"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Secret" = [
        "gnome-keyring"
      ];
      "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
    };
  };
}
