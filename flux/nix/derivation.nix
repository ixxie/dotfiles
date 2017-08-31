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
            cp -R ./lib $out/lib
            find $out/lib -exec chmod u+x {} \;
        '';
    
    runtimeDependency = [ pkgs.bashInteractive ];

    dontPatchShebangs = true;
    
}

