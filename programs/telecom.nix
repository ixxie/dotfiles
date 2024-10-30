{
  pkgs,
  ...
}:

{
  environment = {
    systemPackages = with pkgs; [
      firefox
      chromium
      signal-desktop
      element-desktop
    ];
  };
}
