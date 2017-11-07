{ stdenv, pkgs }:

let

    version = "0.0.2";

in stdenv.mkDerivation 
rec 
{

    name = "flux-${version}";

    src = ../.;

    installPhase =
        ''
            mkdir -p $out
            cp -R ./bin $out/bin
        '';
    
    runtimeDependency = [ pkgs.bashInteractive ];

    dontPatchShebangs = true;
    
}

