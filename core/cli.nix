{ config, pkgs, ... }: 

{
  # Basic Package Suite
  environment = 
  {
    systemPackages = with pkgs; [
      asciiquarium
      cowsay
      cmatrix
      ddate
      docker
      docker_compose
      espeak
      figlet
      file
      git
      home-manager
      htop
      irssi
      lm_sensors
      lolcat
      manpages
      neovim
      morph
      nixUnstable
      nixops
      nix-prefetch-git
      nix-index
      nms
      openssh
      pass
      powerline-go
      ponysay
      speedtest-cli
      vim
      weechat
      testdisk
      terminator
      tmux
      tree
      toilet
      zsh
    ]; 
  };
  
  programs.adb.enable = true;
  
  # admin settings
  security.sudo.wheelNeedsPassword = false;

  virtualisation.docker.enable = true;

}
