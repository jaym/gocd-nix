{ system ? builtins.currentSystem, pkgs ? import <nixpkgs> {inherit system; }, compiler ? "default", ... }:
with pkgs;
stdenv.mkDerivation rec {
  name = "gocd-agent-${version}";
  version = "16.3.0-3183";

  src = fetchzip {
    url = "https://download.go.cd/binaries/16.3.0-3183/generic/go-agent-16.3.0-3183.zip";
    sha256 = "1drgm15w6nnzdg1y0xhlijjmh13lkldq0rcjpn1kbgdh301dh4c7";
  };

  dontbuild = true;

  installPhase = ''
  mkdir -p $out/usr/share/gocd-agent/
  cp -dr --no-preserve=ownership ./*.jar $out/usr/share/gocd-agent/
  cp -dr --no-preserve=ownership ./LICENSE $out/usr/share/gocd-agent/
  '';
}
