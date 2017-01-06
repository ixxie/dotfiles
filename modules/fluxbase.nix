
{ config, pkgs, stdenv,... }: { 

	# Use ZSH for default shell.
	users.defaultUserShell = "/var/run/current-system/sw/bin/zsh";

	environment = 
	{
		systemPackages = 
			with pkgs; 
			[
				calibre
				chromium
				evince
				kodi
				gimp
				gparted
				irssi
				lm_sensors
				manpages
				nix-repl
				skype
				transmission
				transmission_gtk
				vlc
				zsh
			]; 
	};

    nixpkgs.config.chromium = {

		enablePepperFlash = true;
		enablePepperPDF = true;
		
	 };

	services = {

		# Enable the OpenSSH daemon.
		openssh.enable = true;

		# Enable CUPS to print documents.
		printing.enable = true;

	};

}
