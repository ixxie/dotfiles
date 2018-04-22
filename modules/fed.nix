{ config, pkgs, ... }: 

{
    environment = 
	{
		systemPackages = 
			with pkgs;
		  [
        ejabberd        
      ];
  };

 # services.ejabberd.enable = true;

}
