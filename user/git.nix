{ ... }:

{
  programs.git = {
    enable = true;
    userName = "Matan Bendix Shenhav";
    userEmail = "matan@shenhav.fyi";
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      core.editor = "hx";
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
      diff.bin = {
        textconv = "hexdump -v -C";
      };
      alias = {
        squash = "!git add $1 && git commit --amend --no-edit && :";
        up = "!git push origin HEAD && :";
        shove = "!git push -f origin HEAD && :";
        graph = "!git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' $1 && :";
        stats = "!git diff --ignore-all-space --stat $1 && :";
        base = "!git rebase -i $(git merge-base $1 $2) && :";
        comm = "!git add . && git commit -m $1 && :";
        wat = "!git config --get-regexp ^alias && :";
      };
    };
  };
}
