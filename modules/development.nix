{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # general
    gh
    hcloud
    infisical
    # python
    python312Packages.python-lsp-server
    ruff
    uv
    migrate-to-uv
    # web
    nodejs_22
    vscode-langservers-extracted # html/css/json
    nodePackages.typescript-language-server
    nodePackages.svelte-language-server
    nodePackages."@vue/language-server"
    nodePackages.prettier
    prettierd
    eslint_d
    postman
    markdown-oxide
    bun
    # data
    duckdb
    sqlitebrowser
    # system
    nixd
    nodePackages.bash-language-server
  ];

  # version control
  home-manager.users.ixxie = {
    programs.git = {
      enable = true;
      userName = "Matan Bendix Shenhav";
      userEmail = "matan@shenhav.fyi";
      extraConfig = {
        init = {
          defaultBranch = "main";
        };
        push = {
          autoSetupRemote = true;
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
          up = "push origin HEAD";
          shove = "push -f origin HEAD";
          graph = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)'";
          stats = "diff --ignore-all-space --stat";
          base = "rebase -i develop";
          comm = "!git add . && git commit -m $1 && :";
          wat = "config --get-regexp ^alias";
          rm = "branch -D";
          ls = "branch -v";
          cd = "switch $1";
          new = "switch -c";
          root = "!gr && :";
        };
      };
    };
  };

  # docker daemon
  virtualisation.docker.enable = true;

  # android debug bridge
  programs.adb.enable = true;
}
