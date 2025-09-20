{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${system}.default
    inputs.quickshell.packages.${system}.default
  ];

  services.noctalia-shell.enable = true;

  home-manager.users.ixxie = {
    imports = [
      inputs.noctalia.homeModules.default
    ];

    programs.noctalia-shell = {
      enable = true;
      settings = ./settings.json;
    };

    #home.file.".config/noctalia/settings.json".text = builtins.readFile ./settings.json;
    home.file.".config/noctalia/colors.json".text = builtins.readFile ./colors.json;
  };
}
