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
				devilspie2
				evince
				unstable.google-chrome
				kodi
				gimp
				gparted
				irssi
				lm_sensors
				manpages
				nix-repl
				openssh
				skype
				transmission_gtk
				vlc
				qemu
				simple-scan
				testdisk
				zsh
			]; 
	};

	services = 
	{

		# Enable the OpenSSH daemon.
		openssh.enable = true;

		# Enable CUPS to print documents.
		printing.enable = true;

	};

}
