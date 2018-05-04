{
  resources.sshKeyPairs.ssh-key = {};

  fluxbox = { config, pkgs, ... }:
  {
    deployment =
    {
      targetEnv = "digitalOcean";
      digitalOcean =
      {
        enableIpv6 = true;
        region = "ams2";
        size = "512mb";
      };
    };
    imports = [ ../modules ../users ];
  };

}
