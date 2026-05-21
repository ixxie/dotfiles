{
  pkgs,
  inputs,
  ...
}: let
  seccomp =
    pkgs.runCommand "claude-seccomp" {
      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/@anthropic-ai/sandbox-runtime/-/sandbox-runtime-0.0.37.tgz";
        hash = "sha256-DuANvt7rBcRubDINPTPeREy6+i3TNFyvwVsG9Un2X6A=";
      };
    } ''
      mkdir -p $out
      tar xzf $src --strip-components=4 package/vendor/seccomp/x64/
      cp * $out/
      chmod +x $out/apply-seccomp
    '';
in {
  imports = [
    ./personal.nix
    ./qualia.nix
  ];

  config.home-manager.users.ixxie = {
    home.packages = with pkgs; [
      inputs.claude-code.packages.x86_64-linux.default
      curl
      wget
      jq
      yq-go
      ripgrep
      fd
      tree
      file
      unzip
      playwright-driver.browsers
      (writeShellScriptBin "playwright" ''
        export PLAYWRIGHT_BROWSERS_PATH="${playwright-driver.browsers}"
        export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1
        exec ${nodejs_22}/bin/npx playwright@${playwright-driver.version} "$@"
      '')
    ];
    home.file.".npm/lib/node_modules/@anthropic-ai/sandbox-runtime/vendor/seccomp/x64".source = seccomp;
  };
}
