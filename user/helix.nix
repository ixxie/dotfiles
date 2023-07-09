{ pkgs, ... }:

{
  programs.helix = {
    enable = true;
    settings = {
      theme = "catppuccin_frappe";
      editor = { shell = [ "nu" "--stdin" "-c" ]; };
    };
    languages.languages = [
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
        name = "html";
        auto-format = true;
      }
      {
        name = "css";
        auto-format = true;
      }
      {
        name = "javascript";
        auto-format = true;
      }
      {
        name = "typescript";
        auto-format = true;
      }
    ];
  };
}
