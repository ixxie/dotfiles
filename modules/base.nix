{ config, pkgs, ... }: 

{ 

	nixpkgs.config = 
    {
        # Allow proprietary packages
        allowUnfree = true;

        # Create an alias for the unstable channel
        packageOverrides = pkgs: 
        {
            unstable = import <nixos-unstable> 
                { 
                    config = config.nixpkgs.config; 
                };
        };
    };

	# Basic Package Suite
	environment = 
	{
		systemPackages = 
			with pkgs; 
			[
				ddate
                                docker
				emacs25-nox
				file
				git
				htop
				irssi
				lm_sensors
				manpages
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

	services = 
	{
		# Enable the OpenSSH daemon.
		openssh.enable = true;

		xserver = 
		{
			# Enter keyboard layout
			layout = "us";
			xkbVariant = "altgr-intl";

		};
	};

}
