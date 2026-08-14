{pkgs, config, ...}: let
  s = config.scheme;
  tuigreet = "${pkgs.tuigreet}/bin/tuigreet";
  # The aggregated wayland/x session files (niri lands here via
  # programs.niri.enable). Point tuigreet at this explicitly: without it,
  # tuigreet falls back to /usr/share (empty on NixOS) and login works only
  # because --remember-session cached an absolute store path to a session
  # file — which dangles the moment a rebuild + GC moves and removes it,
  # giving "no command defined" with no session list to recover from.
  sessions = "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
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
      # --sessions makes the picker find niri fresh every boot; --cmd is the
      # last-resort command so a missing/empty session list can never again
      # strand login at "no command defined".
      command = "${tuigreet} --time --remember-session --sessions ${sessions} --cmd niri-session --asterisks --theme '${theme}'";
      user = "greeter";
    };
  };
}
