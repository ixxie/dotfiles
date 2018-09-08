{ config, pkgs, ... }: 

{

  # fluxcluster
  
  environment =
  {
    systemPackages =
    with pkgs;
    [
      hcloud
    ];
  };
  
  programs.ssh.knownHosts = 
  [
    {
      hostNames = [
        "flux-master" "95.216.166.39"
      ]; 
      publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDTn0bswjzeKeuRW95GPtkG2bmAOwEOmMq7/+wxAvxnD828E0UklDBk8keNJJp9QoWlnSvKtr8Ph3L12CwbCXZzabp328phV9amT7KrjNdLEejmIF3UW5aBrrXEHKNTJc9l+pUbPf0V+fzMJrbkBwa5pXIKD+DAflmiYYxDcd2T7rKG5PI3oXwt2HPpwHzrM/Ahx1DeqMRMaBLE+Hpomyq8PmxYTxdBI+ozhyWOku3+RDgitGyzb79/tvWsh+id21o+1U/bLS+bUES5NlJjxNfx2PDTXSK5ypkPtrlBoOUdYN18p6E0WMkpj4ayuCriE5keys8eQAM0tD7MasGeO9RQOyiCMzX4cvm8qUITjmglqiM7ByYka+zwQy9zpiTVKsU1f7BDL2uO4rq3z3HeZjeJYDFemSfR0GQ06j/1aKwrdFXLubBVIZ1wuu6ClEwelsO13+QXnt1Ls913JdSumXnJJwFtYtIxqVgNT1fED441Qv+WYLUlaS7MItSMQt2Tu305x7zb+m533qSyZQtYcMGcBnvKXvUs1RdwjIugwt/oIMPOuxu7gZlDZ28s/lmCEL7d7liNvjrDf3BXO8xtlrIkIRZj11p5bTlOBCqjVrsjevBKHFHhI9U1IVnkSI6uM26Zd226RhhwPnWp/le1QwgOV/HcQ/KcAcwqaKbhDemwaw==";
    }
    {
      hostNames = [
        "flux-dev" "95.216.165.250"
      ]; 
      publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRW6djPX4oVjZ2gbS/8S0M9+n9bwY+D00QCNZGM+8jzSuftFYDEdHPPDqqvlJ7DnymCGlClPdbu7IYxcnweU9wM9WtaR3p0VUOIq2tU+y35EpCgm0+zSM3+OT2giDB+g2JPIgewWK3hezShFvQrxPrJSdGLBMdx3Lk5yQG0V+9NVyCF9pBmS0EJQwIwIHxBo0oz03AyIt9HSrPcja1yR/hTJ4TgyZurAhfcDvjYOcvQCl1y6ste0xMF8PVSRadWzFNQuMjBKEp5feuAv++U3Y16jPkr3EuD1CpKTYElfbYMZEktHwPFQl2KGaoPNDqrj80zjJ/lnAD9XiJJU9ngJwIPb0+lPZWaHSgNRLueftLWtNW5HK98f3a+HbtQGsBECHKs3yz5HH+OYl5XbHl9Su2hSdo6AkAfUi+p7af+3WNba5v2RIrijzMnTq9r/kk9aDkYoLYGtpq6OtT4xifYOaCqh2L0cfOzHvQmqlpSEkzpgci4ztY8yurfLuZbMRqMO+P0ufXiFAsGFyc2at2pXqOpKA/tXnFadOjiDxCKSHW8C3kZEnAxPPYxbaXosIR21WsHqtXZLFqDupMOHPI9QPu4SVhUiYIepxHUMbTHmcXQv4RIwTrXzBrKEegERLWwwWPIvkyGy1IScH6QFTUFLdgJ2u6TMg/0NUKKOjcwmi7Rw==";
    }
  ];
  
  networking.extraHosts = ''
    95.216.166.39   flux-master
    95.216.165.250  flux-dev
  '';
  
}
