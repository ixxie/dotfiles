{ config, pkgs, ... }: 


{
    # The NixOS release
    system.stateVersion = "17.09";

    # Include the following configuration modules:
    imports =
        [
            ./users/ixxie.nix
	    ./systems/fluxbox-hardware-config.nix
	    ./systems/fluxbox-networking.nix
            ./modules/flux.nix
            ./modules/base.nix
            ./modules/sci.nix
            ./modules/irc.nix
            ./modules/jupyterhub.nix
        ];

     networking.hostName = "fluxbox";
     services.ircClient.enable = true;
     services.ircClient.user = "ixxie";
}
