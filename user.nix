{ pkgs, ... }:

{
  home-manager = {
    backupFileExtension = "backup";
    users.ixxie.home = {
      stateVersion = "24.05";
      username = "ixxie";
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
