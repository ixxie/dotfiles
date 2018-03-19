{ ... }: {
  # This file was populated at runtime with the networking
  # details gathered from the active system.
  networking = {
    nameservers = [
      "2001:4860:4860::8844"
      "8.8.8.8"
      "2001:4860:4860::8888"
    ];
    defaultGateway = "95.85.35.1";
    defaultGateway6 = "";
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          { address="95.85.35.107"; prefixLength=24; }
{ address="10.14.0.5"; prefixLength=16; }
        ];
        ipv6.addresses = [
          { address="2a03:b0c0:0:1010::83:4001"; prefixLength=64; }
{ address="fe80::3c48:6aff:fe28:a9b8"; prefixLength=64; }
        ];
      };
      
    };
  };
  services.udev.extraRules = ''
    ATTR{address}=="3e:48:6a:28:a9:b8", NAME="eth0"
    
  '';
}
