{inputs, ...}: {
  imports = [inputs.pi-mono.nixosModules.default];

  config.programs.pi.coding-agent = {
    enable = true;
    users = ["ixxie"];
  };
}
