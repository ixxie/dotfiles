{ pkgs, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    users.ixxie =
      { ... }:
      {
        imports = [
          ./alacritty.nix
          ./git.nix
          ./nushell.nix
          ./helix.nix
          ./gnome.nix
        ];

        home = {
          stateVersion = "24.05";
          username = "ixxie";
        };
      };
  };
  users.users.ixxie = {
    home = "/home/ixxie";
    extraGroups = [
      "wheel"
      "networkmanager"
      "adbusers"
      "audio"
      "docker"
    ];
    isNormalUser = true;
    shell = pkgs.nushell;
    useDefaultShell = false;
  };
}
