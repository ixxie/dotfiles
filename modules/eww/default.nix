{
  pkgs,
  ...
}:

{
  home-manager.users.ixxie = {
    programs.eww = {
      enable = true;
      configDir = ./.; # Use the current directory for config
      package = pkgs.eww;
    };

    # Add dependencies for the eww bar
    home.packages = with pkgs; [
      jq
      brightnessctl
      pamixer
    ];

    # Add systemd service for eww
    systemd.user.services.eww = {
      Unit = {
        Description = "Eww Daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.eww}/bin/eww daemon --no-daemonize";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
