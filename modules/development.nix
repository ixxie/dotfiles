{
  pkgs,
  config,
  paseo-pkg,
  ...
}: {
  services.paseo = {
    enable = true;
    user = "ixxie";
    package = paseo-pkg;
  };

  # Make PASEO_PASSWORD available to interactive shells (CLI).
  # secretEnv declares the sops secret with owner=ixxie; we reuse that
  # secret in the template below for the systemd unit.
  secretEnv."paseo-password" = "PASEO_PASSWORD";

  sops.templates."paseo.env" = {
    content = ''
      PASEO_PASSWORD=${config.sops.placeholder."paseo-password"}
    '';
    owner = "ixxie";
  };

  systemd.services.paseo.serviceConfig.EnvironmentFile =
    config.sops.templates."paseo.env".path;

  environment.systemPackages = with pkgs; [
    # general
    gh
    hcloud
    infisical
    concurrently
    # python
    python312Packages.python-lsp-server
    ruff
    uv
    migrate-to-uv
    # web
    nodejs_22
    vscode-langservers-extracted # html/css/json
    typescript-language-server
    svelte-language-server
    prettier
    eslint_d
    postman
    marksman
    bun
    # data
    duckdb
    # system
    nixd
    alejandra
    bash-language-server
    # etc
    showmethekey
    android-tools
    # agents
    socat
  ];

  home-manager.users.ixxie = {
    programs.direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
    };

    programs.git = {
      enable = true;
      signing.format = null;
      settings = {
        user = {
          name = "Matan Bendix Shenhav";
          email = "matan@shenhav.fyi";
        };
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
          base = "!git fetch && git rebase -i origin/develop && :";
          comm = "!git add . && git commit -m $1 && :";
          wat = "config --get-regexp ^alias";
          rm = "branch -D";
          ls = "branch -v";
          cd = "switch $1";
          new = "switch -c";
          root = "!gr && :";
          grab = "!f() { url=$1; owner=$(echo $url | cut -d'/' -f4); repo=$(echo $url | cut -d'/' -f5); branch=$(echo $url | cut -d'/' -f7); remote=\"$owner-$repo\"; git remote add $remote https://github.com/$owner/$repo 2>/dev/null || true; git fetch $remote $branch && git checkout -b $branch $remote/$branch 2>/dev/null || git checkout $branch; }; f";
        };
      };
    };
  };

  secretEnv."hetzner-api-key" = "HCLOUD_TOKEN";
  secretEnv."openrouter-api-key" = "OPENROUTER_API_KEY";

  # docker daemon
  virtualisation.docker.enable = true;
}
