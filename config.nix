{ config, pkgs, lib, ...}:
{
  options.zerovpn = {
    client = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      keyfile = lib.mkOption {
        type = lib.types.str;
        default = "";
      }; 

      key = lib.mkOption {
        type = lib.types.str;
        default = "";
      };

      interface = lib.mkOption {
        type = lib.types.str;
        default = "wg0";
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = config.networking.hostName;
      };

      serverName = lib.mkOption {
        type = lib.types.str;
      };

      serverHost = lib.mkOption {
        type = lib.types.str;
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

    server = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };

      keyfile = lib.mkOption {
        type = lib.types.str;
        default = "";
      };

      clientName = lib.mkOption {
        type = lib.types.str;
        default = config.networking.hostName;
      };

      endpointPort = lib.mkOption {
        type = lib.types.int;
        default = 4242;
      };
  
      announcePort = lib.mkOption {
        type = lib.types.int;
        default = 4243;
      };

    };
  };

  config.systemd.services.zerovpnClient = lib.mkIf config.zerovpn.client.enable {
    enable = true;
    wantedBy = [ "multiuser.target" ];
    path = [ pkgs.procps pkgs.wireguard-tools pkgs.netcat-openbsd pkgs.iproute2 pkgs.zerovpn pkgs.openresolv ];
    script = "${pkgs.zerovpn}/bin/0vpn-leaf ${config.zerovpn.client.interface} /etc/zerovpn-key ${config.zerovpn.client.serverName} ${config.zerovpn.client.serverHost} ${builtins.toString config.zerovpn.client.endpointPort} ${builtins.toString config.zerovpn.client.announcePort} ${builtins.toString config.zerovpn.client.announceInterval} ${config.zerovpn.client.name}";
  };

  config.users.users.zerovpn = {
    isSystemUser = true; 
    group = "zerovpn";
  };

  config.users.groups.zerovpn = { };

  config.environment.etc.zerovpn-key = lib.mkIf config.zerovpn.client.enable {
    text = config.zerovpn.client.key;
    mode = "0440";
    user = "zerovpn";
  };
}
