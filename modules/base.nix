{ config, pkgs, ... }: 

{ 

    nixpkgs.config = 
    {
        # Allow proprietary packages
        allowUnfree = true;

      #  # Create an alias for the unstable channel
      #  packageOverrides = pkgs: 
      #  {
      #      unstable = import <nixos-unstable> 
      #          { 
      #              config = config.nixpkgs.config; 
      #          };
      #  };
    };

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
                            openssh
                            speedtest-cli
                            vim
                            testdisk
                            tmux
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

            xserver = 
            {
                    # Enter keyboard layout
                    layout = "us";
                    xkbVariant = "altgr-intl";

            };
    };

}
