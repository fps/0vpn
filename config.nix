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
      };

      host = lib.mkOption {
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

      keyfile = lib.mkOption {
        type = lib.types.str;
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

      name = lib.mkOption {
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

      keyfile = lib.mkOption {
        type = lib.types.str;
      }; 
    };

  };
}
