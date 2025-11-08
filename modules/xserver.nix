{pkgs, ...}: {
  services = {
    xserver.enable = true;
    displayManager.gdm.enable = true;
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

  services.printing.enable = true;

  xdg.portal.config = {
    common = {
      "org.freedesktop.impl.portal.FileChooser" = "gtk";
    };
    niri = {
      default = [
        "wlr"
        "gtk"
      ];
      "org.freedesktop.impl.portal.ScreenCast" = ["wlr"];
      "org.freedesktop.impl.portal.Screenshot" = ["wlr"];
      "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
    };
    gnome = {
      default = [
        "gnome"
        "gtk"
      ];
      "org.freedesktop.impl.portal.Secret" = [
        "gnome-keyring"
      ];
      "org.freedesktop.impl.portal.FileChooser" = ["gtk"];
    };
  };
}
