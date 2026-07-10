{
  config,
  pkgs,
  ...
}: let
  protonEmail = "matan@shenhav.fyi";
  bridgeCert = "/home/ixxie/.config/protonmail/bridge-v3/cert.pem";
in {
  # One-time setup (do BEFORE the first rebuild that includes this module,
  # otherwise sops will fail because `proton-bridge-password` won't exist yet):
  #   1. `nix shell nixpkgs#protonmail-bridge -c protonmail-bridge --cli`
  #      then in the REPL: `login` → Proton creds + 2FA → `info` (copy the
  #      16-char IMAP password) → `exit`.
  #   2. `sops ~/repos/lab/dotfiles/secrets.yaml` → add line:
  #        proton-bridge-password: <that-password>
  #   3. `yo gen switch`
  #   4. `proton.sync DKIM`  (or any other Proton folder name)

  sops.secrets.proton-bridge-password = {
    owner = "ixxie";
  };

  environment.systemPackages = with pkgs; [
    protonmail-bridge
    isync
  ];

  home-manager.users.ixxie = {
    programs.mbsync.enable = true;

    accounts.email = {
      maildirBasePath = "mail";
      accounts.proton = {
        primary = true;
        address = protonEmail;
        userName = protonEmail;
        realName = "Matan Bendix Shenhav";
        passwordCommand = "cat ${config.sops.secrets.proton-bridge-password.path}";
        imap = {
          host = "127.0.0.1";
          port = 1143;
          tls = {
            enable = true;
            useStartTls = true;
            certificatesFile = bridgeCert;
          };
        };
        mbsync = {
          enable = true;
          create = "maildir";
          remove = "none";
          expunge = "none";
          patterns = [ "*" ];
          extraConfig.remote.PathDelimiter = "/";
        };
      };
    };

    systemd.user.services.protonmail-bridge = {
      Unit = {
        Description = "Proton Mail Bridge (headless)";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
      };
      Service = {
        ExecStart = "${pkgs.protonmail-bridge}/bin/protonmail-bridge --noninteractive";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "default.target" ];
    };

    programs.fish.functions."proton.sync" = {
      description = "Sync a specific Proton Mail folder into ~/mail/proton/";
      body = ''
        if test (count $argv) -ne 1
          echo "usage: proton.sync <folder>"
          return 1
        end
        mbsync proton:$argv[1]
      '';
    };
  };
}
