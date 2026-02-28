{pkgs, config, ...}: let
  s = config.scheme;
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
  ghosttyTheme = pkgs.writeText "base16" ''
    background = ${s.base00}
    foreground = ${s.base05}
    cursor-color = ${s.base05}
    selection-background = ${s.base02}
    selection-foreground = ${s.base05}
    palette = 0=${s.base00}
    palette = 1=${s.base08}
    palette = 2=${s.base0B}
    palette = 3=${s.base0A}
    palette = 4=${s.base0D}
    palette = 5=${s.base0E}
    palette = 6=${s.base0C}
    palette = 7=${s.base05}
    palette = 8=${s.base03}
    palette = 9=${s.base08}
    palette = 10=${s.base0B}
    palette = 11=${s.base0A}
    palette = 12=${s.base0D}
    palette = 13=${s.base0E}
    palette = 14=${s.base0C}
    palette = 15=${s.base07}
  '';
in {
  xdg.terminal-exec = {
    enable = true;
    settings.default = ["com.mitchellh.ghostty"];
  };

  home-manager.users.ixxie = {
    programs.ghostty = {
      enable = true;
      settings = {
        theme = "base16";
        background-opacity = 0.8;
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

    # base16 theme
    xdg.configFile."ghostty/themes/base16".source = ghosttyTheme;
  };
}
