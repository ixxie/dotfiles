{ config, pkgs, ... }: 

{

    nixpkgs.config.packageOverrides = super: let self = super.pkgs; in
    {

        rEnv = super.rWrapper.override {
            packages = with self.rPackages; [ 
                devtools
                dplyr
                showtext
                ggplot2
                ggrepel
                magrittr
                plyr
                pryr
                RCurl
                ];
        };
    };

    environment = 
	{
		systemPackages = 
			with pkgs;
			[
                ghc
                rEnv
                python35Packages.python
                python35Packages.pandocfilters
            ];
    };

}