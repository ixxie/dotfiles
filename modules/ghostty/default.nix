{ ... }:

{
  home-manager.users.ixxie.programs = {
    ghostty = {
      enable = true;
      settings = {
        window-padding-x = 10;
        window-padding-y = 10;
        gtk-wide-tabs = false;
        gtk-custom-css = "/home/ixxie/repos/dotfiles/modules/ghostty/style.css";
      };
    };
  };
}
