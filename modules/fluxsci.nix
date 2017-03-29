{ config, pkgs, ... }: 

{

    nixpkgs.config.packageOverrides = super: let self = super.pkgs; in
    {

        rEnv = super.rWrapper.override {
            packages = with self.rPackages; [ 
                devtools
                ggplot2
                ];
        };
    };

    environment = 
	{
		systemPackages = 
			with pkgs;
			[
                rEnv
            ];
    };

}