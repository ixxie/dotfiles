{ pkgs, ... }:
 
{

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
                    neotree 
                    tabbar
                    telephone-line
                    use-package
                    which-key
                    intero
                    haskell-mode
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
                userEmail = "matan@fluxcraft.net";

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
