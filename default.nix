{ config, pkgs, ... }:
{
  imports = [
    ./config.nix
  ];

  nixpkgs.overlays = [
    (import ./overlay.nix)
  ];
}
