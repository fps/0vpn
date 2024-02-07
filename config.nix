{ config, pkgs, lib, ...}:
{
  options.zerovpn = {
    client = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = config.networking.hostName;
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

    serverName = lib.mkOption {
      type = lib.types.str;
    };

    key = lib.mkOption {
      type = lib.types.str;
    };

    wireguardDevice = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
    };

    wireguardPort = lib.mkOption {
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

    dnsPort = lib.mkOption {
      type = lib.types.int;
      default = 53;
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (config.zerovpn.client.enable || config.zerovpn.server.enable) { 
      networking.wireguard.enable = true;
  
      users.users.zerovpn = {
        isSystemUser = true; 
        group = "zerovpn";
      };
  
      users.groups.zerovpn = { };    
  
      environment.etc.zerovpn-key = {
        text = config.zerovpn.key;
        mode = "0600";
        user = "zerovpn";
        group = "zerovpn";
      };

      environment.systemPackages = [ pkgs.zerovpn ];
    })
    (lib.mkIf config.zerovpn.client.enable {
      services.resolved.enable = true;
      networking.networkmanager.dns = "systemd-resolved";
      networking.networkmanager.enable = true;

      systemd.services.zerovpnClient = {
        enable = true;
        wantedBy = [ "multi-user.target" ];
        serviceConfig = { Restart = "always"; RestartSec = "1"; };
        unitConfig = { StartLimitIntervalSec = 0; };
        path = [ pkgs.wireguard-tools pkgs.netcat-openbsd pkgs.iproute2 pkgs.zerovpn pkgs.openresolv pkgs.hostname ];
        script = "${pkgs.zerovpn}/bin/0vpn-client --wireguard-device ${config.zerovpn.wireguardDevice} --keyfile /etc/zerovpn-key --server-name ${config.zerovpn.serverName} --server-hostname ${config.zerovpn.serverHost} --wireguard-port ${builtins.toString config.zerovpn.wireguardPort} --announce-port ${builtins.toString config.zerovpn.announcePort} --announce-interval ${builtins.toString config.zerovpn.announceInterval} --client-name ${config.zerovpn.client.name} --dns-port ${builtins.toString config.zerovpn.dnsPort}";
      };
    })
    (lib.mkIf config.zerovpn.server.enable {
      networking.firewall.allowedUDPPorts = [ config.zerovpn.wireguardPort config.zerovpn.announcePort config.zerovpn.dnsPort ];
      systemd.services.zerovpnServer = {
        enable = true;
        wantedBy = [ "multi-user.target" ];
        serviceConfig = { Restart = "always"; RestartSec = "1"; };
        unitConfig = { StartLimitIntervalSec = 0; };
        path = [ pkgs.wireguard-tools pkgs.netcat-openbsd pkgs.iproute2 pkgs.zerovpn pkgs.openresolv pkgs.dnsmasq pkgs.hostname ];
        script = "${pkgs.zerovpn}/bin/0vpn-server --wireguard-device ${config.zerovpn.wireguardDevice} --keyfile /etc/zerovpn-key --server-name ${config.zerovpn.serverName} --server-hostname ${config.zerovpn.serverHost} --wireguard-port ${builtins.toString config.zerovpn.wireguardPort} --announce-port ${builtins.toString config.zerovpn.announcePort} --static-clients " + "\"" + (lib.concatStringsSep " " config.zerovpn.server.staticClients) + "\"" + " --dns-port ${builtins.toString config.zerovpn.dnsPort}";
      };
    })
    ];
}
