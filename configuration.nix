{ config, pkgs, ... }: 


{
    # The NixOS release
	system.stateVersion = "17.09";

    # Include the following configuration modules:
    imports =
        [
            ./users/ixxie.nix
            ./systems/meso.nix
            ./modules/flux.nix
            ./modules/base.nix
            ./modules/sci.nix
            ./modules/gnome.nix
            ./modules/unstable.nix
        ];

}
