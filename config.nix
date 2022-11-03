{ config, pkgs, lib, ...}:
{
  options.zerovpn = {
    client = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      serverName = lib.mkOption {
        type = lib.types.str;
      };
    };

    server = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      staticClients = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
    };

    serverHost = lib.mkOption {
        type = lib.types.str;
    };

    name = lib.mkOption {
      type = lib.types.str;
      default = config.networking.hostName;
    };

    key = lib.mkOption {
      type = lib.types.str;
    };

    interface = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
    };

    endpointPort = lib.mkOption {
      type = lib.types.int;
      default = 4242;
    };

    announcePort = lib.mkOption {
      type = lib.types.int;
      default = 4243;
    };

    announceInterval = lib.mkOption {
      type = lib.types.int;
      default = 60;
    };
};

  # Common configuration
  config.users.users.zerovpn = lib.mkIf (config.zerovpn.client.enable || config.zerovpn.server.enable) {
    isSystemUser = true; 
    group = "zerovpn";
  };

  config.users.groups.zerovpn = lib.mkIf (config.zerovpn.client.enable || config.zerovpn.server.enable) { };

  config.environment.etc.zerovpn-key = lib.mkIf (config.zerovpn.client.enable || config.zerovpn.server.enable) {
    text = config.zerovpn.key;
    mode = "0440";
    user = "zerovpn";
  };

  # Client configuration
  config.systemd.services.zerovpnClient = lib.mkIf config.zerovpn.client.enable {
    enable = true;
    wantedBy = [ "multiuser.target" ];
    path = [ pkgs.procps pkgs.wireguard-tools pkgs.netcat-openbsd pkgs.iproute2 pkgs.zerovpn pkgs.openresolv ];
    script = "${pkgs.zerovpn}/bin/0vpn-leaf ${config.zerovpn.interface} /etc/zerovpn-key ${config.zerovpn.client.serverName} ${config.zerovpn.serverHost} ${builtins.toString config.zerovpn.endpointPort} ${builtins.toString config.zerovpn.announcePort} ${builtins.toString config.zerovpn.announceInterval} ${config.zerovpn.name}";
  };

  # Server configuration
  config.systemd.services.zerovpnServer = lib.mkIf config.zerovpn.server.enable {
    enable = true;
    wantedBy = [ "multiuser.target" ];
    path = [ pkgs.procps pkgs.wireguard-tools pkgs.netcat-openbsd pkgs.iproute2 pkgs.zerovpn pkgs.openresolv pkgs.dnsmasq ];
    script = "${pkgs.zerovpn}/bin/0vpn-root ${config.zerovpn.interface} /etc/zerovpn-key ${config.zerovpn.name} ${config.zerovpn.serverHost} ${builtins.toString config.zerovpn.endpointPort} ${builtins.toString config.zerovpn.announcePort}";
  };
}
