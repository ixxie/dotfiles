# corpus:article/architecture
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    signal-desktop
    element-desktop
    # bwrap's --die-with-parent races niri's spawn double-fork: the intermediate
    # child exits after bwrap has armed PDEATHSIG, so discord is SIGKILLed on
    # launch. keep the FHS env (krisp needs the unpatched binary).
    (discord.override {
      buildFHSEnv = args: buildFHSEnv (args // {dieWithParent = false;});
    })
    cinny
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
