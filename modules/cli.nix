{ pkgs, ... }:

{
  # Basic Package Suite
  environment.systemPackages = with pkgs; [
    file
    gnumake
    htop
    lm_sensors
    man-pages
    ngrok
    openssh
    testdisk
    tree
    lshw
    ripgrep
    ddate
    wget
    unzip
    dig
    p7zip-rar
    rar
    gparted
    simple-scan
    xclip
    lsof
    screenkey
    isoimagewriter
  ];
}
