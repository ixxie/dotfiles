{
  pkgs,
  config,
  ...
}: let
  cleanupRatio = 1.2;
  ns = "torrentvpn";
  wgIp = "10.2.0.2/32";
  peerPublicKey = "m0HsRUbWzTEDSNH9BVrsnGaA9mGaHfQlLDD2ngzgJmc=";
  peerEndpoint = "37.120.137.226:51820";
  vethHost = "172.30.0.1/30";
  vethNs = "172.30.0.2/30";
  proxyPort = 8118;

  tinyproxyConf = pkgs.writeText "tinyproxy.conf" ''
    Port ${toString proxyPort}
    Listen 172.30.0.2
    Timeout 60
    Allow 172.30.0.0/30
    ConnectPort 443
    ConnectPort 80
  '';
in {
  home-manager.users.ixxie.xdg.configFile."yo/config.json".text = builtins.toJSON {
    inherit cleanupRatio;
    proxy = "http://127.0.0.1:${toString proxyPort}";
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

  # protonvpn wireguard key
  sops.secrets.protonvpn-key = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  # network namespace
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

  # wireguard tunnel + veth bridge
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

  # DNS inside namespace
  environment.etc."netns/${ns}/resolv.conf".text = "nameserver 1.1.1.1\nnameserver 9.9.9.9\n";

  # HTTP proxy inside VPN namespace
  systemd.services."proxy-${ns}" = {
    description = "HTTP proxy into ${ns} VPN namespace";
    bindsTo = ["wg-${ns}.service"];
    after = ["wg-${ns}.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      NetworkNamespacePath = "/var/run/netns/${ns}";
      BindReadOnlyPaths = "/etc/netns/${ns}/resolv.conf:/etc/resolv.conf";
      InaccessiblePaths = "/var/run/nscd";
      ExecStart = "${pkgs.tinyproxy}/bin/tinyproxy -d -c ${tinyproxyConf}";
      Restart = "on-failure";
    };
  };

  # forward host localhost -> namespace tinyproxy
  systemd.services."proxy-${ns}-fwd" = {
    description = "Forward HTTP proxy from host to VPN namespace";
    after = ["proxy-${ns}.service"];
    bindsTo = ["proxy-${ns}.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:${toString proxyPort},fork,bind=127.0.0.1,reuseaddr TCP:172.30.0.2:${toString proxyPort}";
      Restart = "on-failure";
    };
  };
}
