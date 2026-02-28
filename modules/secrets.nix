{config, inputs, ...}: {
  imports = [inputs.sops-nix.nixosModules.sops];
  sops = {
    defaultSopsFile = ../secrets.yaml;
    age.keyFile = "/home/ixxie/.config/sops/age/keys.txt";

    secrets.cella-credentials = {
      mode = "0400";
      restartUnits = ["cella-proxy.service"];
    };

    secrets.nix-access-tokens = {
      mode = "0440";
      group = "nixbld";
    };

    secrets.opencode-api-key = {
      owner = "ixxie";
    };

    secrets.zen-api-key = {
      owner = "ixxie";
    };
  };
}
