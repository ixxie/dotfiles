{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    spotify
    celluloid
    sox
  ];

  # audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    wireplumber.enable = true;
    wireplumber.extraConfig.bluetoothEnhancements = {
      "monitor.bluez.properties" = {
        "bluez5.enable-sbc-xq" = true;
        "bluez5.enable-msbc" = true;
        "bluez5.enable-hw-volume" = true;
        # a2dp for hi-fi, hfp_ag for headset mics (we are the gateway).
        # hsp dropped: legacy profile whose SDP lookups kept failing against
        # modern earbuds and racing the hfp connect. bap dropped: LE Audio
        # needs ISO sockets bluetoothd doesn't have enabled — it only
        # produced "Failed to set default system config" noise at boot.
        "bluez5.roles" = [
          "a2dp_sink"
          "a2dp_source"
          "hfp_ag"
        ];
      };
      # Profile choreography is owned by cyberdeck's audio backend, which
      # switches explicitly and verifies each stage. The on-demand autoswitch
      # raced flaky HFP links (RFCOMM reset mid-open) and fought explicit
      # switches, producing connect/disconnect loops.
      "wireplumber.settings" = {
        "bluetooth.autoswitch-to-headset-profile" = false;
      };
    };
  };
  services.pulseaudio.enable = false;
}
