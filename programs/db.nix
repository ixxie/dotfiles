{ config, pkgs, ... }:

#let
#  supabase = with pkgs;
#    buildGoModule rec {
#      pname = "supabase-cli";
#      version = "1.45.2";
#
#      src = fetchFromGitHub {
#        owner = "supabase";
#        repo = "cli";
#        rev = "v${version}";
#        sha256 = "0m2fzpqxk7hrbxsgqplkg7h2p7gv6s1miymv3gvw0cz039skag0s";
#      };
#      vendorHash = null;
#    };
#in 
{
  # Basic Package Suite
  environment = { systemPackages = with pkgs; [ duckdb ]; };
}
