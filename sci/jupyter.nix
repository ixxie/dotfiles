{ config, pkgs, lib, ... }: 

{ 
  environment = {
    systemPackages = with pkgs.python37Packages; [
      jupyter_core
      jupyterlab
    ];
  };
}
