{ config, pkgs, ... }: 

{

  # fluxcluster
  
  environment.systemPackages = with pkgs; [
      hcloud
  ];

  
  programs.ssh.knownHosts = 
  [
    {
      hostNames = [
        "flux-dev" "95.216.165.250"
      ]; 
      publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRW6djPX4oVjZ2gbS/8S0M9+n9bwY+D00QCNZGM+8jzSuftFYDEdHPPDqqvlJ7DnymCGlClPdbu7IYxcnweU9wM9WtaR3p0VUOIq2tU+y35EpCgm0+zSM3+OT2giDB+g2JPIgewWK3hezShFvQrxPrJSdGLBMdx3Lk5yQG0V+9NVyCF9pBmS0EJQwIwIHxBo0oz03AyIt9HSrPcja1yR/hTJ4TgyZurAhfcDvjYOcvQCl1y6ste0xMF8PVSRadWzFNQuMjBKEp5feuAv++U3Y16jPkr3EuD1CpKTYElfbYMZEktHwPFQl2KGaoPNDqrj80zjJ/lnAD9XiJJU9ngJwIPb0+lPZWaHSgNRLueftLWtNW5HK98f3a+HbtQGsBECHKs3yz5HH+OYl5XbHl9Su2hSdo6AkAfUi+p7af+3WNba5v2RIrijzMnTq9r/kk9aDkYoLYGtpq6OtT4xifYOaCqh2L0cfOzHvQmqlpSEkzpgci4ztY8yurfLuZbMRqMO+P0ufXiFAsGFyc2at2pXqOpKA/tXnFadOjiDxCKSHW8C3kZEnAxPPYxbaXosIR21WsHqtXZLFqDupMOHPI9QPu4SVhUiYIepxHUMbTHmcXQv4RIwTrXzBrKEegERLWwwWPIvkyGy1IScH6QFTUFLdgJ2u6TMg/0NUKKOjcwmi7Rw==";
    }
    {
      hostNames = [
        "shenhav" "116.203.149.170"
      ]; 
      publicKey = "SHA256:752X07NNLAX4JsB+BpaB7CHl1iAJUX/5TpJTYiqURQ8.";
    }
  ];
  
  networking.extraHosts = ''
    95.216.165.250  flux-dev
    116.203.149.170 shenhav
  '';
  
}
