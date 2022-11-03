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

      serverName = lib.mkOption {
        type = lib.types.str;
        default = config.networking.hostName;
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
}
