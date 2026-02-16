{
  lib,
  stdenv,
  bun,
  makeWrapper,
}:
stdenv.mkDerivation {
  pname = "org";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [makeWrapper];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/lib/org $out/bin

    cp -r node_modules $out/lib/org/
    cp -r src $out/lib/org/
    cp package.json $out/lib/org/

    makeWrapper ${bun}/bin/bun $out/bin/org \
      --add-flags "$out/lib/org/src/index.ts"
  '';

  meta = with lib; {
    description = "System management CLI";
    mainProgram = "org";
  };
}
