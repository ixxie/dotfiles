{ config, pkgs, ... }: 

{
  # Basic Package Suite
  environment = 
  {
    systemPackages = 
    with pkgs; 
    [
      ddate
      emacs25-nox
      file
      git
      htop
      irssi
      lm_sensors
      manpages
      nixUnstable
      nixops
      nix-prefetch-git
      nix-index
      openssh
      speedtest-cli
      vim
      testdisk
      tmux
      tree
      zsh
    ]; 
  };

  # admin settings
  security.sudo.wheelNeedsPassword = false;
}
