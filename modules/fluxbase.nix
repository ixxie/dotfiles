{ config, pkgs, ... }: 

{ 

	# Basic Package Suite
	environment = 
	{
		systemPackages = 
			with pkgs; 
			[
				calibre
				# chromium
				ddate
				evince
				google-chrome
				kodi
				gimp
				gparted
				irssi
				lm_sensors
				manpages
				nix-repl
				skype
				transmission_gtk
				vlc
				qemu
				zsh
			]; 
	};

    # nixpkgs.config.chromium = 
	# {

	# 	enablePepperFlash = true;
	# 	enablePepperPDF = true;
	# 	enableWideVine = true;
	# };

	services = 
	{

		# Enable the OpenSSH daemon.
		openssh.enable = true;

		# Enable CUPS to print documents.
		printing.enable = true;

	};

}
