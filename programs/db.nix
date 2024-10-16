{ config, pkgs, ... }:

{
  # Basic Package Suite
  environment = {
    systemPackages = with pkgs; [ duckdb ];
  };
}
