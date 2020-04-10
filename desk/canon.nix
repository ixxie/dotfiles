{ config, pkgs, lib, ... }: 

  
with lib;
{ 
    # enable CUPS to print documents.
    services.printing.enable = true;
    
    # scanner support
    hardware.sane.enable = true;

    environment = {
      systemPackages = with pkgs; [
        sane-backends-git
        canon-cups-ufr2
      ];
    };
}
