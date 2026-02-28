{
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    firefox
    chromium
    tor-browser
  ];

  home-manager.users.ixxie = {
    imports = [
      inputs.zen-browser.homeModules.default
    ];
    programs.zen-browser = {
      enable = true;
      suppressXdgMigrationWarning = true;
      policies.Preferences = {
        "widget.use-xdg-desktop-portal.file-picker" = {
          Value = 1;
          Status = "locked";
        };
      };
    };
  };
}
