{config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services.gocd-agent;
  agent_package = import ./agent.nix pkgs;
in
{
  options = {
    services.gocd-agent = {
      enable = mkOption {
        default = true;
        type = types.bool;
        description = ''
          Enable Go Continuous Delivery Agent
        '';
      };
      
      jre = mkOption {
        default = pkgs.jre;
        type = types.package;
      };

      server = {
        host = mkOption {
          type = types.string;
          default = "127.0.0.1";
          description = "The hostname of the GoCD Server";
        };
        port = mkOption {
          type = with types; uniq int;
          default = 8153;
          description = "The port of the GoCD Server";
        };
      };

      stateDir = mkOption {
        type = types.string;
        description = "Where to put assets in the service.";
        default = "/var/lib/gocd-agent";
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
    systemd.services.gocd-agent = {
      wantedBy = [ "multi-user.target" ];
      description = "Run the GoCD Agent";
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
      export PATH=$PATH:${pkgs.nix}/bin:${pkgs.git}/bin
      cd ${cfg.stateDir}
      exec ${cfg.jre}/bin/java -server -jar ${agent_package}/usr/share/gocd-agent/agent-bootstrapper.jar ${cfg.server.host} ${toString cfg.server.port}
      '';
    };
  };
}
