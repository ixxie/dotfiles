{ pkgs, ... }:
 
{
#   home.packages =
#   [
#       pkgs.htop
#       pkgs.fortune
#   ];
 
    home.file.".emacs.d/init.el".source = ../emacs/init.el;
    home.file.".emacs.d/user".source = ../emacs/user;
  
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
                    multi-term
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

                extraConfig =
                    ''
                    [color "branch"]
                        current = green bold
                        local = green
                        remote = yellow

                    [color "diff"]
                        frag = cyan bold
                        meta = yellow bold
                        new = green
                        old = red

                    [diff "bin"]
                        textconv = hexdump -v -C
                    '';

            };
 
    };

}
