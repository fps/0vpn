final: prev: 
{
  zerovpn = prev.buildGoModule rec {
    pname = "zerovpn";
    src = ./.;
    vendorHash = null;
    name = "zerovpn";

    # GOPATH="${out}/gopath";
    # GOCACHE="${out}/gocache";

    configurePhase = ''
      GOPATH=$TMPDIR/gopath
      GOCACHE=$TMPDIR/gocache
      go mod vendor
    '';
  };
}
