{config, pkgs, lib, ...}:

let
  cfg = config.services.ircClient;
in
with lib;
{
  options =
  {
    services.ircClient =
    {
        enable = mkOption
        {
            default = false;
            type = with types; bool;
            description = ''
            Start an irc client for a user.
            '';
        };

        user = mkOption
        {
            default = "username";
            type = with types; uniq string;
            description = ''
            Name of the user.
            '';
        };
    };
  };

  config = mkIf cfg.enable
  {
    systemd.services.ircSession =
    {
        wantedBy = [ "multi-user.target" ]; 
        after = [ "network.target" ];
        description = "Start the irc client of username.";
        serviceConfig = rec {
            Type = "forking";
            User = "${cfg.user}";
            ExecStart = ''${pkgs.tmux}/bin/tmux -2 new-session -d -s irc
                          ${pkgs.irssi}/bin/irssi '';  
            ExecStop = ''${pkgs.tmux}/bin/tmux detach-client -s irc'';
    };
  };

  environment.systemPackages = with pkgs;
    [
      irssi
      tmux
    ];
};

}
