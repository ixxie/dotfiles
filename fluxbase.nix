
{ config, pkgs, stdenv,... }: { 

	# Use ZSH for default shell.
	users.defaultUserShell = "/var/run/current-system/sw/bin/zsh";

	environment = {

		systemPackages = 
			with pkgs; [
				chromium
				kodi
				gimp
				gnome3.geary
				irssi
				lm_sensors
				nix-repl
				numix-gtk-theme
				numix-icon-theme
				skype
				transmission
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
