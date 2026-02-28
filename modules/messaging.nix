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

      [settings]
      username_display = "displayname"
      read_receipt_send = true
      typing_notice_send = true
      reaction_display = true
      user_gutter_width = 20

      [settings.image_preview]
      protocol.type = "kitty"
      size = { width = 64, height = 32 }

      [settings.notifications]
      enabled = true
      show_message = true
      via = "desktop"

      [settings.sort]
      rooms = ["favorite", "unread", "name"]

      [layout]
      style = "restore"
    '';
  };
}
