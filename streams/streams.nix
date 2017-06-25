{ config, pkgs,  ... }: 

let

    # "Sbtix generates a Nix definition that represents your SBT project's
    # dependencies. It then uses this to build a Maven repo containing the 
    # stuff your project needs, and feeds it back to your SBT build."

 sbtix = import
            (pkgs.fetchgit 
                (removeAttrs
                    (builtins.fromJSON
                        (builtins.readFile ./jsons/sbtix.json)
                    )
                    [ "date" "fetchSubmodules" ]
                )
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
