{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.jupyterhub;
  jupyterhub = pkgs.python36Packages.jupyterhub;

  kernels = concatStringsSep ";\n" (mapAttrsToList (kernelName: kernel:
    let
        config = builtins.toJSON {
          argv = [
            "${kernel.env}/bin/${kernel.executable}"
            "-m"
            "ipykernel_launcher"
            "-f"
            "{connection_file}"
          ];
          display_name = kernel.name;
          language = kernel.executable;
        };
      in ''
        mkdir -p kernels/${kernelName};
        echo '${config}' > kernels/${kernelName}/kernel.json
      ''
    ) cfg.kernels);

  kernels_pkg = pkgs.stdenv.mkDerivation rec {
    name = "jupyter-kernels";

    src = "/dev/null";
    unpackCmd ="mkdir jupyter_kernels";
    installPhase =
      ''
        ${kernels}
        mkdir $out
        cp -r kernels $out
      '';
  };

  config_file = pkgs.writeText "jupyter_config.py" ''
    c.Spawner.environment = {
      "JUPYTER_PATH": "${kernels_pkg}"
    }
    ${cfg.appendConfig}
  '';
in
{
  options = {
    services.jupyterhub = {
      enable = mkEnableOption "Jupyterhub spawning server.";
      stateDir = lib.mkOption {
        type = lib.types.str;
        default = "/var/jupyterhub";
        description = "
          Directory holding all state for jupyterhub to run.
        ";
      };
      appendConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = ''
          Configuration appended to the jupyterhub_config.py configuration.
          Can be specified more than once and it's value will be concatenated.
        '';
      };
      kernels = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule (import ./kernel-options.nix {
          inherit config pkgs lib;
        }));

        default = {
          python3 = {};
        };
        example = lib.literalExample ''
          {
            "python3" = {
              name = "Python 3";
              env = (pkgs.python36.withPackages (pythonPackages: with pythonPackages; [
                pycurl
                notebook
                alembic
              ]));
              executable = "python";
              argv = [
                "-m"
                "ipykernel_launcher"
                "-f"
                "{connection_file}"
              ];
              language = "python";
            };
          };
        '';
        description = "Declarative kernel config";
      };
    };
  };

  config = mkIf (cfg.enable) {
    services.nginx.virtualHosts = {
      "jupyter.${config.networking.hostName}" = {
        forceSSL = true;
        extraConfig = ''
          location / {
            proxy_pass http://localhost:8888;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header Host $http_host;
            proxy_http_version 1.1;
            proxy_redirect off;
            proxy_buffering off;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_read_timeout 86400;
          }
        '';
      };
    };

    systemd.services.jupyterhub = {
      description = "Jupyterhub server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [
        "${cfg.stateDir}"
        "${pkgs.nodePackages_6_x.configurable-http-proxy}"
      ];
      preStart = ''
        mkdir -p ${cfg.stateDir}
        ${pkgs.nodejs}/bin/npm install --prefix ${cfg.stateDir} -g configurable-http-proxy
      '';

      serviceConfig = {
        WorkingDirectory = "${cfg.stateDir}";
        ExecStart = ''${jupyterhub}/bin/jupyterhub \
          --port 8888 \
          --config=${config_file}
        '';
        Restart = "always";
        RestartSec = "10s";
        StartLimitInterval = "1min";
      };
    };
  };
}
