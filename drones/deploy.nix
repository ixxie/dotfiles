
{
  codex = { config, pkgs, ... }: {


    imports = [
      ./hardware/codex.nix
      ../modules
      ../users
    ];

    config = {
      deployment = {
        targetHost = "192.168.1.213";
        targetEnv = "none";
      };

      users.extraUsers.fuzzy = {
        home = "/home/fuzzy";
        extraGroups = [
            "networkmanager"
        ];
        isNormalUser = true;
      };

      desktop = "gnome";

      # broadcom drivers
      nixpkgs.config.allowUnfree = true;

      # Use the systemd-boot EFI boot loader.
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Enable the OpenSSH daemon.
      services.openssh.enable = true;

      # Don't touch this
      system.stateVersion = "18.03";
      
      users.users.root = {
        openssh.authorizedKeys.keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOm2JiPs6geaZ+coOju+kpUIbaJkLOnydTGcPc+K4V5ksqkqDW2i2fPjZdV3U8Eihv+wUmyYkj5SU+Q75JYy1/0oKwWQi2SX9EqrSsK/JOryex8FmqwhKwm7+afrryILCOJyhhNGeKOm04stxY50UDSrCmOSpyX15PZnMPB6BRuWdiWi3jvGwja2+lFwtKlIJuYooBFCAE7R7buqHgduhvtoLWTh8sLRiKDo9vP7s63qyXmvCx7tY06lSD3V65rRBd6SjA8mqHQZN9RL0RgJry65HVMIE2BapniLeUJi2L32hvttstvkj2PMA0Obm+bxlimKSSXZkTRPoxC/p3tWy7 ixxie@meso"
        ];
      };
    };
  };
}
