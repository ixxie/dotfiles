{ config, pkgs, ... }: 

{
  environment = 
	{
		systemPackages = 
			with pkgs;
			[
            python36Packages.python
            python36Packages.jupyter
            python36Packages.notebook
            python36Packages.jupyterhub
            python36Packages.jupyterlab
            python36Packages.scikitlearn
      ];
  };
}
