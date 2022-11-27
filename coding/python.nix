{ config, pkgs, ... }:
with pkgs;
let
  pypackages = python-packages:
    with python-packages; [
      flake8
      autopep8
      poetry
    ];
  python = python3.withPackages pypackages;
in { environment.systemPackages = with pkgs; [ python ]; }
