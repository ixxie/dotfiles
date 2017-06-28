{ config, pkgs,  ... }: 

with builtins;

let

    streamsDir = ../streams;

    streamFiles = map 
                    (file: streamsDir + ("/" + file) ) 
                    (attrNames (readDir streamsDir));

    fetchStream = 
            (jsonFile: 
                pkgs.fetchgit 
                        (removeAttrs
                            (fromJSON
                                (readFile jsonFile)
                            )
                            [ "date" "fetchSubmodules" ]
                        )
            );

    importStream =
            (stream:
                import "${stream}/nix/derivation.nix" {}
            );

    streams = map fetchStream streamFiles;
    pkglist = map importStream streams;

in

{ 
    environment = 
        {
            systemPackages = pkglist;
        };
}
