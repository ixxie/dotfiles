{ stdenv, fetchzip }:

fetchzip {
  name = "interUI-3.2";

  url = "https://github.com/rsms/inter/releases/download/v3.2/Inter-UI-3.2.zip";
  sha256 = "0yrxnis60b9cdc8inv8y4d3jwb1nb5vq132g9l8w78879jpk31fq";

  postFetch = ''
    unzip $downloadedFile
    mkdir -p $out/share/fonts/truetype
    cp './Inter UI (TTF hinted)/'*.ttf $out/share/fonts/truetype
  '';
  meta = {
    description = "A Unicode font";
    maintainers = [ stdenv.lib.maintainers.raskin ];
    platforms = stdenv.lib.platforms.unix;
  };
}
