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

            variables = 
            {
                FLUX_HOME = [ "/home/ixxie/Fluxstack" ];
            };
        }; 
    };
}
