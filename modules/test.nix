{ config, pkgs, ... }: 

{
  services = {

    # experimenting with a new jupyterlab service
    jupyterlab = {

      enable = true;

      notebookDir = "/var/srv/jupyterlab";

      password = "'sha1:b49552cf8a60:63e19fd78d2b9e9b4e99bdc8a808724e4f95a434'";

      kernels = {
         python3 = let
           env = (pkgs.python3.withPackages (pythonPackages: with pythonPackages; [
                   ipykernel
                   pandas
                   scikitlearn
                 ]));
         in {
           displayName = "Python 3 for machine learning";
           argv = [
             "${env.interpreter}"
             "-m"
             "ipykernel_launcher"
             "-f"
             "{connection_file}"
           ];
           language = "python";

         };
       };
     };
  };
}
