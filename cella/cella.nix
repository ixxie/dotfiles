{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.cella.nixosModules.server
    inputs.cella.nixosModules.client
  ];

  cella = {
    client = {
      enable = true;
      user = "ixxie";
      vmConfig = ./vm;
      servers.grove = "root@95.216.229.121";
      sync = ["~/.claude.json"];
    };

    server = {
      enable = true;
      nat.interface = "wlp1s0";

      vm = {
        mounts = {
          "/home/ixxie/.claude" = {mountPoint = "/home/ixxie/.claude";};
          "/home/ixxie/.ssh" = {
            mountPoint = "/home/ixxie/.ssh";
            readOnly = true;
          };
        };

        copyFiles = {
          "/home/ixxie/.claude.json" = "/home/ixxie/.claude.json";
        };
      };

      egress = {
        writes.allowed = [
          "api.anthropic.com"
          "*.anthropic.com"
          "claude.com"
          "*.claude.com"
        ];

        passthrough = [
          "claude.ai"
          "*.claude.ai"
          "*.anthropic.com"
        ];
      };

      nucleus.enable = true;

      user = {
        name = "ixxie";
        authorizedKeys = [
          (builtins.readFile /home/ixxie/.ssh/id_ed25519.pub)
        ];
      };
    };
  };

  environment.systemPackages = [
    inputs.cella.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
