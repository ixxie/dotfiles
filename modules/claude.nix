{
  lib,
  pkgs,
  ...
}: let
  seccomp = pkgs.runCommand "claude-seccomp" {
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

  # Shared Claude settings - reused in cell/home.nix
  claudeSettings = {
    hasCompletedOnboarding = true;
    theme = "dark";
    preferredNotifChannel = "terminal";
  };

  claudeMd = ''
    # Communication style

    - Be concise in your responses
    - Don't bother explaining what you did in great detail: I'll ask if I need details
    - Avoid hyperbolic expressions and be direct
    - Don't be sycophantic: provide pushback and critical feedback (but not judgemental)
    - Once in a while, make a joke, but don't make it cheesy: be creative, use dark humor and nerdy jokes
    - Use the following emojis to express the tone of your response
    - If you think of an architectural pattern, library or tool that can help my project, suggest it an provide a link

    # Coding style

    - Indent with spaces and never tabs
    - Ensure empty lines have no indentation
    - Be concise when naming variables, functions and classes
    - You may omit words from a name if they are clear from context
    - Only use comments in the following cases:
      * To clarify complex code
      * To explain why something was done, if it is not immediately obvious
      * To group sequences of expression in a long scope and clarify steps (but don't use numbering)
    - No oneline ifs: always use cuddles / indented block.

    ## Shell

    I use fish; for all shell commands, assume this is the shell.

    I am in a NixOS environment: if you need access to a CLI tool and don't find it, you may use `nix shell` commands.

    ## JS/TS Projects

    I use a variety of tools, so check in the current project whether npm, bun or pnpm are used.

    Prefer modern ES6 syntax.

    Use ?? rather than || where it makes sense to do so.

    ## Svelte

    Assume Svelte 5 unless there is evidence to the contrary.

    ## Python projects

    Always use uv to manage the project if there is a `uv.lock`.

    # Security

    - When generating code with some cryptographic keys, *always* provide an authorative link to
      allow me to verify them.

  '';
in {
  # Export for reuse in cell/home.nix
  options.claude = {
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = claudeSettings;
      description = "Claude Code settings";
    };
    md = lib.mkOption {
      type = lib.types.str;
      default = claudeMd;
      description = "CLAUDE.md content";
    };
  };

  config.home-manager.users.ixxie = {
    programs.claude-code.enable = true;
    home.file.".claude/settings.json".text = builtins.toJSON claudeSettings;
    home.file.".claude/CLAUDE.md".text = claudeMd;
    # Claude Code searches ~/.npm for seccomp binaries from @anthropic-ai/sandbox-runtime
    home.file.".npm/lib/node_modules/@anthropic-ai/sandbox-runtime/vendor/seccomp/x64".source = seccomp;
  };
}
