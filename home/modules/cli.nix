# corpus:article/architecture
{pkgs, ...}: let
  viu-desktop = pkgs.makeDesktopItem {
    name = "viu";
    desktopName = "viu";
    exec = "ghostty -e viu -n %f";
    mimeTypes = [
      "image/png"
      "image/jpeg"
      "image/gif"
      "image/webp"
      "image/bmp"
      "image/svg+xml"
      "image/tiff"
    ];
    noDisplay = true;
  };
  vercel = pkgs.callPackage ../../pkgs/vercel.nix {};
in {
  # Basic Package Suite
  environment.systemPackages = with pkgs; [
    ddate
    dig
    file
    gnumake
    gparted
    htop
    libnotify
    ledger
    lm_sensors
    lshw
    lsof
    man-pages
    ngrok
    openssh
    p7zip-rar
    rar
    _1password-cli
    _1password-gui
    viu
    viu-desktop
    ripgrep
    sway-launcher-desktop
    grim
    slurp
    wayfreeze
    wl-screenrec
    wl-clipboard
    screenkey
    simple-scan
    testdisk
    tree
    unzip
    uv
    vercel
    wget
    # desktop utilities
    tumbler
    xarchiver
  ];
}
