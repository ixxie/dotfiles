{ config, pkgs, ... }: 

{ 
	# Basic Package Suite
	environment = 
	{
		systemPackages = 
			with pkgs; 
			[
				ddate
				devilspie2
				evince
				google-chrome
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
