{ pkgs, ... }:

{
  # Basic Package Suite
  environment.systemPackages = with pkgs; [
    ddate
    dig
    file
    gnumake
    gparted
    htop
    isoimagewriter
    ledger
    lm_sensors
    lshw
    lsof
    man-pages
    ngrok
    openssh
    p7zip-rar
    rar
    ripgrep
    screenkey
    simple-scan
    testdisk
    tree
    unzip
    wget
    xclip
  ];
}
