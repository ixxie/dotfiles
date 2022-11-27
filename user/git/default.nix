{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Matan Bendix Shenhav";
    userEmail = "matan@shenhav.fyi";
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
        sq = "!git add $1 && git commit --amend -C HEAD && :";
        pf = "!git push -f origin HEAD && :";
        ds = "!git diff --ignore-all-space --stat $1 && :";
        bm = "!git rebase -i $(git merge-base $1 $2) && :";
        ac = "!git add . && git commit && :";
        cm = "!git commit -m $1 && :";
        poh = "!git push origin HEAD && :";
        wat = "!git config --get-regexp ^alias && :";
      };
    };
  };
}
