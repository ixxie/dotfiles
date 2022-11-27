{ pkgs, ... }:

{
  users.users.ixxie = {
    home = "/home/ixxie";
    extraGroups = [ "wheel" "networkmanager" "docker" "adbusers" "audio" ];
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDOm2JiPs6geaZ+coOju+kpUIbaJkLOnydTGcPc+K4V5ksqkqDW2i2fPjZdV3U8Eihv+wUmyYkj5SU+Q75JYy1/0oKwWQi2SX9EqrSsK/JOryex8FmqwhKwm7+afrryILCOJyhhNGeKOm04stxY50UDSrCmOSpyX15PZnMPB6BRuWdiWi3jvGwja2+lFwtKlIJuYooBFCAE7R7buqHgduhvtoLWTh8sLRiKDo9vP7s63qyXmvCx7tY06lSD3V65rRBd6SjA8mqHQZN9RL0RgJry65HVMIE2BapniLeUJi2L32hvttstvkj2PMA0Obm+bxlimKSSXZkTRPoxC/p3tWy7 ixxie@meso"
    ];
    shell = pkgs.fish;
  };
  home-manager.users.ixxie = { pkgs, ... }: {
    imports = [ ./neovim ./tmux ./git ./vscodium ./fish ];

    programs.home-manager = {
      enable = true;
      path = "https://github.com/rycee/home-manager/archive/master.tar.gz";
    };

    home = {
      sessionPath = [ "/home/ixxie/repos/global-node-modules/bin" ];
      stateVersion = "22.05";
      username = "ixxie";
    };
  };
}
