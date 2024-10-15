{ pkgs, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    users.ixxie = { pkgs, ... }: {
      imports =
        [ ./alacritty.nix ./git.nix ./vscodium.nix ./nushell.nix ./helix.nix ];

      home = {
        sessionPath = [ "/home/ixxie/repos/.utilities/node-modules/bin" ];
        stateVersion = "24.05";
        username = "ixxie";
      };
    };
  };
  users.users.ixxie = {
    home = "/home/ixxie";
    extraGroups = [ "wheel" "networkmanager" "adbusers" "audio" ];
    isNormalUser = true;
    openssh = {
      authorizedKeys.keys = [
      ];
    };
    shell = pkgs.nushell;
    useDefaultShell = false;
  };
}
