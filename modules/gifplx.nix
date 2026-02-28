{inputs, pkgs, ...}: {
  environment.systemPackages = [
    inputs.gifplx.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
