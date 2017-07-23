{ config, pkgs, ... }: 

{

    nixpkgs.config.packageOverrides = super: let self = super.pkgs; in
    {
        rEnv = super.rWrapper.override 
        {
            packages = 
                with self.rPackages; 
                [ 
                    DBI
                    devtools
                    distr
                    dplyr
                    igraph
                    showtext
                    ggnetwork
                    ggplot2
                    lubridate
                    magrittr
                    matrixcalc
                    network
                    plyr
                    poweRlaw
                    pryr
                    RCurl
                    RSQLite
                ];
        };
    };

    environment = 
	{
		systemPackages = 
			with pkgs;
			[
                ghc
                python35Packages.python
                python35Packages.pandocfilters
                rEnv
                sqlite-interactive
            ];
    };

}