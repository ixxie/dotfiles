{
  pkgs,
  ...
}:

{
  environment = {
    # add some desktop applications
    systemPackages = with pkgs; [
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
  };
  networking.enableIPv6 = false;
}
