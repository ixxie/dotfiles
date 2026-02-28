{pkgs, config, ...}: let
  s = config.scheme;
  theme = builtins.concatStringsSep ";" [
    "border=black"
    "text=white"
    "prompt=blue"
    "time=darkgray"
    "action=cyan"
    "button=green"
    "container=black"
    "input=white"
  ];
in {
  # set VT palette to base16 scheme
  console.colors = [
    s.base00 # 0  black
    s.base08 # 1  red
    s.base0B # 2  green
    s.base0A # 3  yellow
    s.base0D # 4  blue
    s.base0E # 5  magenta
    s.base0C # 6  cyan
    s.base05 # 7  white
    s.base03 # 8  bright black (darkgray)
    s.base08 # 9  bright red
    s.base0B # 10 bright green
    s.base0A # 11 bright yellow
    s.base0D # 12 bright blue
    s.base0E # 13 bright magenta
    s.base0C # 14 bright cyan
    s.base07 # 15 bright white
  ];

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --asterisks --window-padding 2 --theme '${theme}' --cmd niri-session";
      user = "greeter";
    };
  };
}
