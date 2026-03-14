{config, ...}: {
  # system-wide orgos defaults — all enrolled users inherit these
  orgos.server.enable = true;
  orgos.cell.enable = true;
  orgos.flow = {
    enable = true;
    graphs.implement = {
      nodes = {
        start = { handler = "start"; label = "begin"; };
        read_spec = { handler = "shell"; label = ''cat "$SPEC"''; };
        plan = {
          handler = "llm";
          label = "Analyze the spec above. Produce a concise implementation plan: list files to change and describe each change.";
        };
        approve = { handler = "human"; label = "Review the plan. Approve to proceed."; };
        implement = {
          handler = "shell";
          label = ''org agent run -p "Read the spec at $SPEC and implement it step by step."'';
        };
        verify = { handler = "shell"; label = ''eval "''${VERIFY:-echo done}"''; };
        done = { handler = "exit"; label = "complete"; };
      };
      edges = [
        { from = "start"; to = "read_spec"; }
        { from = "read_spec"; to = "plan"; }
        { from = "plan"; to = "approve"; }
        { from = "approve"; to = "implement"; }
        { from = "implement"; to = "verify"; }
        { from = "verify"; to = "done"; }
      ];
    };
  };

  orgos.agent = {
    enable = true;
    default_model = "kimi-k2.5";
    providers = [
      {
        provider = "openai";
        base_url = "https://opencode.ai/zen";
        api_key_env = "ZEN_API_KEY";
      }
    ];
  };

  # secrets
  sops.secrets.zen-api-key.owner = "ixxie";

  home-manager.users.ixxie.programs.fish.interactiveShellInit = ''
    if test -f ${config.sops.secrets.zen-api-key.path}
      set -gx ZEN_API_KEY (cat ${config.sops.secrets.zen-api-key.path})
    end
  '';
}
