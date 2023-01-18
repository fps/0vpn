final: prev: 
{
  zerovpn = prev.buildGoModule rec {
    pname = "zerovpn";
    src = ./.;
    # vendorHash = null;
    vendorSha256 = null;
    name = "zerovpn";
    propagatedBuildInputs = [ prev.wireguard-tools prev.netcat-openbsd ];
    postInstall = ''
      echo installing scripts...
      install -d $out/bin
      install 0vpn-* $out/bin/
    '';
   };
}
