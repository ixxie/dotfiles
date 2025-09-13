{
  pkgs,
  inputs,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${system}.default
    inputs.quickshell.packages.${system}.default
  ];

  home-manager.users.ixxie = {
    home.file.".config/noctalia/settings.json".text = builtins.readFile ./settings.json;
    home.file.".config/noctalia/colors.json".text = builtins.readFile ./colors.json;
  };
}
