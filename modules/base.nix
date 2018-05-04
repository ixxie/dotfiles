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
      nix-repl
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
  
  programs.ssh.extraConfig = ''
    ServerAliveInterval 120
    ServerAliveCountMax 720
  '';
  services = 
  {
    # Enable the OpenSSH daemon.
    openssh =
    {
      enable = true;
      extraConfig = ''
        ClientAliveInterval 120
        ClientAliveCountMax 720
      '';
    };
  };

}
