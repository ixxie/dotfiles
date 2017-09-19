{ pkgs, ... }:
 
{
#   home.packages =
#   [
#       pkgs.htop
#       pkgs.fortune
#   ];
 
 
    programs =
    {
            emacs =
            {
                enable = true;
                extraPackages = epkgs: with epkgs;
                [
                    base16-theme
                    evil
                    magit
                    nix-mode
                    projectile
                    rainbow-mode
                    smartparens
                    telephone-line
                    use-package
                    which-key
                ];
            };
 
            zsh =
            {
                enable = true;
 
            };
 
            git =
            {
                enable = true;
                userName = "Matan Shenhav";
                userEmail = "matan.shenhav@sievo.com";
            };
 
    };

}