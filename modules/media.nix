{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    spotify
    celluloid
  ];

  # audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    wireplumber.enable = true;
  };
  services.pulseaudio.enable = false;
}
