{pkgs, ...}: let
  ghosttyCss = pkgs.writeText "ghostty-style.css" ''
    headerbar {
      margin: -5px;
      padding: 0;
      background: none;
      height: 10px;
    }

    tabbox,
    tab,
    button {
      min-height: 10px;
      height: 10px;
      margin: 0px;
    }
  '';
in {
  home-manager.users.ixxie.programs = {
    ghostty = {
      enable = true;
      settings = {
        font-size = 11;
        window-padding-x = 10;
        window-padding-y = 10;
        gtk-wide-tabs = false;
        gtk-custom-css = "${ghosttyCss}";
        keybind = [
          "shift+enter=text:\x1b\r"
        ];
      };
    };
  };
}
