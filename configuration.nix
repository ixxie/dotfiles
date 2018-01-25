{ config, pkgs, ... }: 


{
    # The NixOS release
    system.stateVersion = "17.09";

    # Include the following configuration modules:
    imports =
        [
            ./users/ixxie.nix
	    ./systems/fluxbox-hardware-config.nix
	    ./systems/fluxbox-networking.nix
            ./modules/flux.nix
            ./modules/base.nix
            ./modules/irc.nix
            ./modules/jupyterhub.nix
        ];

     networking.hostName = "fluxbox";
     services.ircClient.enable = true;
     services.ircClient.user = "ixxie";

     services.jupyterhub.enable = true; 

     services.nginx.enable = true;

#     services.nginx.virtualHosts.jupyter.fluxbox = {
#         sslCertificate = pkgs.writeText "sslCertificate" (builtins.readFile ./modules/ssl.cert);
#        sslCertificateKey = pkgs.writeText "sslCertificate" (builtins.readFile ./modules/ssl.key);
#     };
            
     services.jupyterhub.appendConfig = ''
        # jupyterhub_config.py file
        c = get_config()

        import os
        pjoin = os.path.join

        runtime_dir = os.path.join('/home/ixxie/jupyter')
        ssl_dir = pjoin(runtime_dir, 'ssl')
        if not os.path.exists(ssl_dir):
            os.makedirs(ssl_dir)

        # Allows multiple single-server per user
        c.JupyterHub.allow_named_servers = True

        # https on :443
        c.JupyterHub.port = 443
        c.JupyterHub.ssl_key = pjoin(ssl_dir, 'ssl.key')
        c.JupyterHub.ssl_cert = pjoin(ssl_dir, 'ssl.cert')

        # put the JupyterHub cookie secret and state db
        # in /var/run/jupyterhub
        c.JupyterHub.cookie_secret_file = pjoin(runtime_dir, 'cookie_secret')
        c.JupyterHub.db_url = pjoin(runtime_dir, 'jupyterhub.sqlite')
        # or `--db=/path/to/jupyterhub.sqlite` on the command-line

        # use GitHub OAuthenticator for local users
        c.JupyterHub.authenticator_class = 'oauthenticator.LocalGitHubOAuthenticator'
        c.GitHubOAuthenticator.oauth_callback_url = 'https://95.85.35.107/hub/oauth_callback'
        c.JupyterHub.proxy_cmd = ['configurable-http-proxy']

        # create system users that don't exist yet
        c.LocalAuthenticator.create_system_users = True

        # specify users and admin
        c.Authenticator.whitelist = {'ixxie'}
        c.Authenticator.admin_users = {'ixxie'}

        # start single-user notebook servers in ~/assignments,
        # with ~/assignments/Welcome.ipynb as the default landing page
        # this config could also be put in
        # /etc/jupyter/jupyter_notebook_config.py
        #c.Spawner.notebook_dir = '~/assignments'
        #c.Spawner.args = ['--NotebookApp.default_url=/notebooks/Welcome.ipynb']i
       '';
}
