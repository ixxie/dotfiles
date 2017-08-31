{ config, pkgs, ... }:


let

    flux = (import ../flux/nix {});

in
{

    config =
    {
        environment.systemPackages = [ flux ];
    };
    
}