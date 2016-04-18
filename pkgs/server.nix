{ system ? builtins.currentSystem, pkgs ? import <nixpkgs> {inherit system; }, compiler ? "default", ... }:
with pkgs;
stdenv.mkDerivation rec {
  name = "gocd-server-${version}";
  version = "16.3.0-3183";

  src = fetchzip {
    url = "https://download.go.cd/binaries/16.3.0-3183/generic/go-server-16.3.0-3183.zip";
    sha256 = "078shs82564ch5crvl7593dirg5c39nmaxdcsj8345canp47ljy2";
  };

  dontbuild = true;

  installPhase = ''
  mkdir -p $out/usr/share/gocd-server/
  cp -dr --no-preserve=ownership ./*.jar $out/usr/share/gocd-server/
  cp -dr --no-preserve=ownership ./LICENSE $out/usr/share/gocd-server/
  '';
}
