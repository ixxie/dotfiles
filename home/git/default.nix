{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Matan Shenhav";
    userEmail = "matan@fluxcraft.net";
    extraConfig = {
      color = {
        branch = {
          current = "green bold";
          local = "green";
          remote = "yellow";
        };
        diff = {
          frag = "cyan bold";
          meta = "yellow bold";
          new = "green";
          old = "red";
        };
      };
      diff.bin = { textconv = "hexdump -v -C"; };
      alias = {
        squash = "!git add $1 && git commit --amend -C HEAD && :";
        sq = "!git squash . && :";
        toss = "!git push origin HEAD && :";
        shove = "!git push -f origin HEAD && :";
      };
    };
  };
}
