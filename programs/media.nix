{
  pkgs,
  ...
}:

{
  environment = {
    # add some desktop applications
    systemPackages = with pkgs; [
      spotify
      vlc
      evince
      transmission_4-gtk
      prismlauncher
      minecraft
    ];
  };
}
