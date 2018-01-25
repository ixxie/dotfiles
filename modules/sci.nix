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
                            python36Packages.python
                            python36Packages.jupyter
                            python36Packages.notebook
                            python36Packages.jupyterlab
                            rEnv
                            sqlite-interactive
                        ];
    };
}
