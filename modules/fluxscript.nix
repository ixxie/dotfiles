{ config, pkgs, ... }:

let

    makeProg = args: pkgs.substituteAll 
    (args // 
        {
            dir = "bin";
            isExecutable = true;
        }
    );

    flux = makeProg 
    {
        name = "flux";
        src = ./flux.sh;
    };

in

{

    options = { };

    config = 
    {
        environment = 
        {
            systemPackages =
            [ 
                flux
            ];
        };

        security = 
        {
            sudo = 
            {
                extraConfig = 
                ''
                    Defaults:root,%wheel env_keep+=FLUX_HOME
                '';
            };
        }; 
    };
}