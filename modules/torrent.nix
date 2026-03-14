{
  pkgs,
  config,
  ...
}: let
  cleanupRatio = 1.2;
  ns = "prowlarrvpn";
  wgIp = "10.2.0.2/32";
  wgDns = "10.2.0.1";
  peerPublicKey = "m0HsRUbWzTEDSNH9BVrsnGaA9mGaHfQlLDD2ngzgJmc=";
  peerEndpoint = "37.120.137.226:51820";
  # veth pair for host <-> namespace communication
  vethHost = "172.30.0.1/30";
  vethNs = "172.30.0.2/30";
in {
  home-manager.users.ixxie.xdg.configFile."yo/config.json".text = builtins.toJSON {
    inherit cleanupRatio;
  };

  # torrent daemon
  services.transmission = {
    enable = true;
    package = pkgs.transmission_4;
    user = "ixxie";
    group = "users";
    settings = {
      download-dir = "/home/ixxie/temp";
      incomplete-dir = "/home/ixxie/temp/.incomplete";
      incomplete-dir-enabled = true;
      port-forwarding-enabled = true;
      peer-port = 49164;
      encryption = 1;
      dht-enabled = true;
      pex-enabled = true;
      utp-enabled = true;
      rpc-bind-address = "127.0.0.1";
      rpc-whitelist-enabled = true;
      speed-limit-up-enabled = true;
      speed-limit-up = 23;
    };
  };

  # torrent search aggregator
  services.prowlarr.enable = true;

  # protonvpn wireguard key
  sops.secrets.protonvpn-key = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  # network namespace for prowlarr VPN isolation
  systemd.services."netns@" = {
    description = "%I network namespace";
    before = ["network.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute2}/bin/ip netns add %I";
      ExecStop = "${pkgs.iproute2}/bin/ip netns del %I";
    };
  };

  # wireguard tunnel + veth bridge inside the namespace
  systemd.services."wg-${ns}" = {
    description = "WireGuard tunnel for ${ns}";
    bindsTo = ["netns@${ns}.service"];
    requires = ["network-online.target"];
    after = ["netns@${ns}.service" "network-online.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writers.writeBash "wg-up" ''
        # wireguard tunnel — configure before moving to namespace
        ${pkgs.iproute2}/bin/ip link add wg0 type wireguard
        ${pkgs.wireguard-tools}/bin/wg set wg0 \
          private-key ${config.sops.secrets.protonvpn-key.path} \
          peer ${peerPublicKey} \
          endpoint ${peerEndpoint} \
          persistent-keepalive 25 \
          allowed-ips 0.0.0.0/0,::/0
        ${pkgs.iproute2}/bin/ip link set wg0 netns ${ns}
        ${pkgs.iproute2}/bin/ip -n ${ns} address add ${wgIp} dev wg0
        ${pkgs.iproute2}/bin/ip -n ${ns} link set wg0 up
        ${pkgs.iproute2}/bin/ip -n ${ns} route add default dev wg0

        # veth pair for host access to prowlarr UI
        ${pkgs.iproute2}/bin/ip link add veth-${ns} type veth peer name veth-ns
        ${pkgs.iproute2}/bin/ip link set veth-ns netns ${ns}
        ${pkgs.iproute2}/bin/ip address add ${vethHost} dev veth-${ns}
        ${pkgs.iproute2}/bin/ip link set veth-${ns} up
        ${pkgs.iproute2}/bin/ip -n ${ns} address add ${vethNs} dev veth-ns
        ${pkgs.iproute2}/bin/ip -n ${ns} link set veth-ns up
        ${pkgs.iproute2}/bin/ip -n ${ns} link set lo up
      '';
      ExecStop = pkgs.writers.writeBash "wg-down" ''
        ${pkgs.iproute2}/bin/ip -n ${ns} route del default dev wg0
        ${pkgs.iproute2}/bin/ip -n ${ns} link del wg0
        ${pkgs.iproute2}/bin/ip link del veth-${ns}
      '';
    };
  };

  # DNS inside the namespace (not ProtonVPN DNS — NetShield blocks torrent sites)
  environment.etc."netns/${ns}/resolv.conf".text = "nameserver 1.1.1.1\nnameserver 9.9.9.9\n";

  # bind prowlarr to the VPN namespace
  systemd.services.prowlarr = {
    bindsTo = ["wg-${ns}.service"];
    after = ["wg-${ns}.service"];
    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/${ns}";
      BindReadOnlyPaths = "/etc/netns/${ns}/resolv.conf:/etc/resolv.conf";
      # block nscd socket so glibc falls back to /etc/resolv.conf
      InaccessiblePaths = "/var/run/nscd";
    };
  };

  # FlareSolverr — headless browser to bypass Cloudflare protection
  systemd.services.flaresolverr = {
    description = "FlareSolverr proxy for Cloudflare bypass";
    bindsTo = ["wg-${ns}.service"];
    after = ["wg-${ns}.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.flaresolverr}/bin/flaresolverr";
      NetworkNamespacePath = "/var/run/netns/${ns}";
      BindReadOnlyPaths = "/etc/netns/${ns}/resolv.conf:/etc/resolv.conf";
      InaccessiblePaths = "/var/run/nscd";
      Environment = "LOG_LEVEL=info";
      Restart = "on-failure";
    };
  };

  # forward host localhost:9696 -> namespace localhost:9696
  systemd.services."prowlarr-proxy" = {
    description = "Forward Prowlarr UI from VPN namespace";
    after = ["prowlarr.service"];
    bindsTo = ["prowlarr.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:9696,fork,bind=127.0.0.1,reuseaddr EXEC:'${pkgs.iproute2}/bin/ip netns exec ${ns} ${pkgs.socat}/bin/socat STDIO TCP\\:127.0.0.1\\:9696'";
      Restart = "on-failure";
    };
  };
}
