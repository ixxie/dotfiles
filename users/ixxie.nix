{ pkgs, ... }: 

{ 
    users.extraUsers = 
        { 
            ixxie = 
            {
                description = "Matan Bendix Shenhav";
                home = "/home/ixxie";
                extraGroups = [ "wheel" "networkmanager" ];
                isNormalUser = true;
                uid = 1000;
                shell = pkgs.zsh;
                createHome = true;
            };
        };
    # * Password is set using the ‘passwd <username>’ command. 
}