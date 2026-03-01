{
  lib,
  stdenv,
  bun,
  makeWrapper,
}:
stdenv.mkDerivation {
  pname = "yo";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [makeWrapper];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/lib/yo $out/bin

    cp -r node_modules $out/lib/yo/
    cp -r src $out/lib/yo/
    cp package.json $out/lib/yo/

    makeWrapper ${bun}/bin/bun $out/bin/yo \
      --add-flags "$out/lib/yo/src/index.ts"
  '';

  meta = with lib; {
    description = "System management CLI";
    mainProgram = "yo";
  };
}
