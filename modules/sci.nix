{ config, pkgs, ... }: 

{
  environment = 
	{
		systemPackages = 
			with pkgs.python36Packages;
			[
            python
            jupyter_core
            jupyter
            ipykernel
            notebook
            jupyterhub
            jupyterlab
            scikitlearn
            scrapy
            nltk
      ];
  };
}
