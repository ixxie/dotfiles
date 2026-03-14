{
  pkgs,
  ...
}: let
  cleanupRatio = 1.2;
in {
  home-manager.users.ixxie.xdg.configFile."yo/config.json".text = builtins.toJSON {
    inherit cleanupRatio;
  };

  # torrent daemon
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    user = "ixxie";
    group = "users";
    settings = {
      download-dir = "/home/ixxie/temp";
      incomplete-dir = "/home/ixxie/temp/.incomplete";
      incomplete-dir-enabled = true;
      port-forwarding-enabled = true;
      peer-port = 49164;
      encryption = 1;
      dht-enabled = true;
      pex-enabled = true;
      utp-enabled = true;
      rpc-bind-address = "127.0.0.1";
      rpc-whitelist-enabled = true;
      speed-limit-up-enabled = true;
      speed-limit-up = 23;
    };
  };
}
