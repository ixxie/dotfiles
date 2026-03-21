{inputs, pkgs, ...}: {
  environment.systemPackages = [
    inputs.cella.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
