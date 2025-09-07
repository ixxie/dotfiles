{ pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      displayManager.gdm.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    xfce.tumbler
    xarchiver
    nautilus
    where-is-my-sddm-theme
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
    common = {
      # Electron apps and chromium fail to open the file picker for some reason.
      "org.freedesktop.impl.portal.FileChooser" = "gtk";
    };
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
