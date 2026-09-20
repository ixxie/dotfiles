# Vercel CLI is not in nixpkgs (it went away with nodePackages), and the npm
# package pulls a dependency tree that is not fully published. Vercel ships an
# official standalone binary per platform, so we take that.
#
# To update: bump version, set hash to lib.fakeHash, build, paste the hash nix
# reports back.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}:
stdenv.mkDerivation (final: {
  pname = "vercel";
  version = "59.23.2";

  src = fetchurl {
    url = "https://registry.npmjs.org/@vercel/vc-native-linux-x64/-/vc-native-linux-x64-${final.version}.tgz";
    hash = "sha256-VnP39N5EmeYy+iF0oqfKytyfVJSpw1DKnrihvZGiN08=";
  };

  nativeBuildInputs = [autoPatchelfHook];
  buildInputs = [stdenv.cc.cc.lib];

  dontBuild = true;
  dontStrip = true; # the binary embeds a node SEA blob

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/vercel $out/bin/vercel
    ln -s vercel $out/bin/vc
    runHook postInstall
  '';

  meta = {
    description = "Vercel CLI";
    homepage = "https://vercel.com/docs/cli";
    license = lib.licenses.asl20;
    platforms = ["x86_64-linux"];
    mainProgram = "vercel";
  };
})
