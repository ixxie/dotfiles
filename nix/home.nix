{ pkgs, ... }:
 
{
   home.packages = with pkgs;
   [
       emacs25-nox
       emacs-all-the-icons-fonts
       python36Packages.flake8
   ];

    home.file.".tmux.conf".source = ../tmux/tmux.conf;
 
    home.file.".emacs.d/init.el".source = ../emacs/init.el;
    home.file.".emacs.d/init".source = ../emacs/init;
  
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
                    tabbar
                    telephone-line
                    use-package
                    which-key
                    flycheck
                    flycheck-pycheckers
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
