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
          EDITOR = "hx";
          BROWSER = "firefox";
          TERMINAL = "ghostty";
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
  };
}
