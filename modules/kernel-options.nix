# Options that can be used for creating a jupyter kernel.
{ config, pkgs, lib }:

with lib;
{
  options = {
    name = mkOption {
      type = types.str;
      default = "Python 3";
      description = ''
        Name to use for the kernel.
      '';
    };

    env = mkOption {
      type = types.package;
      default = (pkgs.python36.withPackages (
        pythonPackages: with pythonPackages; [
          pycurl
          notebook
          alembic
        ])
      );
      description = ''
        The environment used to create the kernel.
        Typically an executable and the wanted libraries.
      '';
    };

    executable = mkOption {
      type = types.str;
      default = "python";
      description = ''
        Name of the executable that will be called by the notebook spawner.
      '';
    };

    argv = mkOption {
      type = types.listOf types.str;
      default = [
        "-m"
        "ipykernel_launcher"
        "-f"
        "{connection_file}"
      ];
      description = ''
        Arguments to pass to the kernel launcher.
      '';
    };

    language = mkOption {
      type = types.str;
      default = executable;
      description = ''
        Language of the environment. Typically the name of the binary.
      '';
    };
  };
}
