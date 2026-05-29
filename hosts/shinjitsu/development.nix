# Global development tools and settings
{ pkgs, ... }:
let
  cajVirtualIp = "127.0.0.2";
  cajForwardedPorts = [
    [
      46297
      80
    ]
    [
      42205
      443
    ]
    [
      3306
      3306
    ]
  ];
in
{
  # MARK: Docker
  virtualisation.docker = {
    enable = false;
    rootless = {
      # We use docker rootless
      enable = true;
      setSocketVariable = true;
      daemon.settings = {
        dns = [
          # Manually configure DNS due to Tailscale overriding Docker's defaults
          "1.1.1.1"
          "8.8.8.8"
          "100.100.100.100"
        ];
      };
    };
  };
  # Needed to correctly forward packets to the docker containers
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.ip_forward" = 1;

  # MARK: CAJ website

  # Add a secondary loopback IP to map the hostnames to
  networking.interfaces.lo.ipv4.addresses = [
    {
      address = cajVirtualIp;
      prefixLength = 8;
    }
  ];
  # hosts file entries
  networking.hosts = {
    "${cajVirtualIp}" = [
      "www-dev.caj.ac.jp"
      "staff-dev.caj.ac.jp"
    ];
  };
  # iptables rules to forward ports from the secondary IP to the appropriate local ports
  # which are port forwarded from the docker container by devcontainers
  networking.firewall.extraCommands = pkgs.lib.strings.concatMapStrings (
    portPair:
    let
      from = builtins.toString (builtins.elemAt portPair 0);
      to = builtins.toString (builtins.elemAt portPair 1);
    in
    ''
      iptables -t nat -A PREROUTING -p tcp -d ${cajVirtualIp} --dport ${to} -j DNAT --to-destination 127.0.0.1:${from}
      iptables -t nat -A OUTPUT -p tcp -d ${cajVirtualIp} --dport ${to} -j DNAT --to-destination 127.0.0.1:${from}
    ''
  ) cajForwardedPorts;
}
