{
  pkgs,
  ...
}:

{
  environment = {
    systemPackages = with pkgs; [
      # browsers
      firefox
      chromium
      tor-browser
      # messaging
      signal-desktop
      element-desktop
      # media
      spotify
      vlc
      evince
      # p2p
      transmission_4-gtk
    ];
  };
}
