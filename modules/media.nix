{ pkgs, ... }:

{
  environment = {
    systemPackages = with pkgs; [
      # browsers
      firefox
      chromium
      tor-browser
      # messaging
      signal-desktop-bin
      element-desktop
      discord
      vesktop
      # media
      spotify
      vlc
      # p2p
      transmission_4-gtk
    ];
  };

  # audio
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    wireplumber.enable = true;
  };
  services.pulseaudio.enable = false;
}
