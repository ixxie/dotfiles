{config, ...}: {
  sops = {
    defaultSopsFile = ../secrets.yaml;
    age.keyFile = "/home/ixxie/.config/sops/age/keys.txt";

    secrets.cella-credentials = {
      mode = "0400";
      restartUnits = ["cella-proxy.service"];
    };
  };
}
