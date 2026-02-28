{pkgs, config, ...}: let
  s = config.scheme;
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  theme = builtins.concatStringsSep ";" [
    "border=${s.base0D}"
    "text=${s.base05}"
    "prompt=${s.base0D}"
    "time=${s.base03}"
    "action=${s.base0B}"
    "button=${s.base0D}"
    "container=${s.base00}"
    "input=${s.base05}"
  ];
in {
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
      command = "${tuigreet} --time --remember-session --asterisks --theme '${theme}'";
      user = "greeter";
    };
  };
}
