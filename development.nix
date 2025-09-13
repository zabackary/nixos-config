{ pkgs, ... }:
let
  cajVirtualIp = "127.0.0.2";
  cajForwardedPorts = [
    [44095 80]
    [37477 443]
    [3306 3306]
  ];
in
{
  # Node.js development with pnpm, etc.
  # I know this shouldn't be system-wide but I have a lot of legacy projects that I don't want to update
  environment.systemPackages = with pkgs; [
    corepack_24
    nodejs_24
  ];

  # Docker
  virtualisation.docker = {
    # Consider disabling the system wide Docker daemon
    enable = false;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.ip_forward" = 1;

  # CAJ website
  networking.interfaces.lo.ipv4.addresses = [
    { address = "127.0.0.2"; prefixLength = 8; }
  ];
  networking.hosts = {
    "127.0.0.2" = [ "www-dev.caj.ac.jp" "staff-dev.caj.ac.jp" ];
  };
  networking.firewall.extraCommands = pkgs.lib.strings.concatMapStrings (portPair: let
    from = builtins.toString (builtins.elemAt portPair 0);
    to = builtins.toString (builtins.elemAt portPair 1);
  in ''
    iptables -t nat -A PREROUTING -p tcp -d ${cajVirtualIp} --dport ${to} -j DNAT --to-destination 127.0.0.1:${from}
    iptables -t nat -A OUTPUT -p tcp -d ${cajVirtualIp} --dport ${to} -j DNAT --to-destination 127.0.0.1:${from}
  '') cajForwardedPorts;
}
