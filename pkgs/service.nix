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

[vagrant@nixbox:~/gocd]$ cat service.nix 
{config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.gocd-server;
  server_package = import ./server.nix pkgs;
in
{
  options = {
    services.gocd-server = {
      enable = mkOption {
        default = true;
        type = types.bool;
        description = ''
          Enable Go Continuous Delivery Server
        '';
      };
      
      jre = mkOption {
        default = pkgs.jre;
        type = types.package;
      };

      http = {
        port = mkOption {
          type = with types; uniq int;
          default = 8153;
          description = "The TCP port to listen on";
        };
      };

      stateDir = mkOption {
        type = types.string;
        description = "Where to put assets in the service.";
        default = "/var/lib/gocd-server";
      };

      user = {
        name = mkOption {
          type = with types; uniq string;
          default = "root";
          description = ''
            The user to run as
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.gocd-server = {
      wantedBy = [ "multi-user.target" ];
      description = "Run the GoCD Server";
      serviceConfig = {
        PermissionsStartOnly = true;
        User = cfg.user.name;
        Restart = "on-failure";
        RestartSec = 5;
        StartLimitInterval = "1min";
      };
      preStart = ''
      mkdir -p -m 0766 ${cfg.stateDir}
      '';

      script = ''
      cd ${cfg.stateDir}
      exec ${cfg.jre}/bin/java -server -Duser.language=en -Djruby.rack.request.size.threshold.bytes=30000000 -Dcruise.config.dir=${cfg.stateDir} -Dcruise.config.file=${cfg.stateDir}/cruise-config.xml -Dcruise.server.port=${toString cfg.http.port} -jar ${server_package}/usr/share/gocd-server/go.jar
      '';
    };
  };
}
