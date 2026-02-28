{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    signal-desktop-bin
    element-desktop
    discord
    iamb
  ];

  home-manager.users.ixxie = {
    xdg.configFile."iamb/config.toml".text = ''
      [profiles.ixxie]
      user_id = "@ixxie:matrix.org"
      url = "https://matrix.org"
    '';
  };
}
