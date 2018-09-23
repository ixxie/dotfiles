{ config, pkgs, ... }: 

{
  # Basic Package Suite
  environment = 
  {
    systemPackages = with pkgs; [
      ddate
      file
      git
      htop
      irssi
      lm_sensors
      manpages
      neovim
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
