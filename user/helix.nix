{ pkgs, ... }:

{
  programs.helix = {
    enable = true;
    settings = { theme = "catppuccin_frappe"; };
    languages = [
      {
        name = "nix";
        auto-format = true;
        language-server = { command = "rnix-lsp"; };
        formatter = { command = "nixfmt"; };
      }
      {
        name = "svelte";
        auto-format = true;
      }
      {
        name = "typescript";
        auto-format = true;
      }
      {
        name = "javascript";
        auto-format = true;
      }
    ];
  };
}
