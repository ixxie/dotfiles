{ config, pkgs,  ... }: 

let

    # "Sbtix generates a Nix definition that represents your SBT project's
    # dependencies. It then uses this to build a Maven repo containing the 
    # stuff your project needs, and feeds it back to your SBT build."

    sbtix = import 
            ( pkgs.fetchFromGitHub 
                { 
                    owner = "teozkr"; 
                    repo = "Sbtix"; 
                    rev = "d4e59eaecb46a74c82229a1d326839be83a1a3ed";
                    sha256 = "1fy7y4ln63ynad5v9w4z8srb9c8j2lz67fjsf6a923czm9lh5naf";
                }
            );
in

{ 
    environment = 
        {
            systemPackages = 
                [
                    sbtix 
                ];
        };
}
