{pkgs, ...}: {
  services.tailscale = {
    enable = true;
    package = pkgs.tailscale;
    useRoutingFeatures = "client";
    extraSetFlags = ["--operator=ixxie"];
    extraUpFlags = ["--operator=ixxie"];
  };

  environment.systemPackages = [pkgs.tailscale];
}
