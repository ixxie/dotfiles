{ pkgs, inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];
  home-manager = {
    backupFileExtension = "backup";
    users.ixxie = {
      nixpkgs.config.allowUnfree = true;
      home = {
        stateVersion = "24.05";
        username = "ixxie";
        sessionVariables = {
          EDITOR = "helix";
          BROWSER = "firefox";
          TERMINAL = "ghostty";
          NIXOS_OZONE_WL = "1";
        };
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
