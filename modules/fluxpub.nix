{ config, pkgs, ... }: 

let

fluxtex = 
        (
            pkgs.texlive.combine 
                {
                    inherit (pkgs.texlive) scheme-small;
                }
        );
in 

{ 

environment = 
{
		systemPackages = 
			with pkgs; 
			[
                fluxtex
                pandoc
            ];
};

}
