# The host half: the machine, its boot and network, and nix itself.
{
  imports = [
    ./device.nix
    ./hardware.nix
    ./nix.nix
    ./system.nix
  ];
}
