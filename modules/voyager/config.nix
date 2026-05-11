{ lib, writeText
, overlay ? {}
, layout ? {}
, colors ? {}
, cache ? {}
, logging ? {}
, ...
}:

let
  defaultColors = {
    accent = "83c092";
    background = "272e33";
    key_fill = "2e383c";
    key_border = "414b50";
    key_text = "d3c6aa";
    layer_highlight = "7fbbb3";
    dim_text = "859289";
  };

  cfg = {
    overlay = {
      width = 480;
      height = 220;
      font_size = 10;
      label_mode = "short";
      margin = 0;
    } // overlay;

    colors = defaultColors // colors;

    layout = {
      keyboard = "voyager";
      layout_macro = "LAYOUT_voyager";
    } // layout;

    cache = {
      dir = "~/.local/share/voyager/cache";
    } // cache;

    logging = {
      db_path = "~/.local/share/voyager/keylog.duckdb";
      socket_path = "~/.config/.keymapp/keymapp.sock";
    } // logging;
  };

  tomlContent = ''
    [overlay]
    width = ${toString cfg.overlay.width}
    height = ${toString cfg.overlay.height}
    font_size = ${toString cfg.overlay.font_size}
    label_mode = "${cfg.overlay.label_mode}"
    margin = ${toString cfg.overlay.margin}

    [colors]
    accent = "${cfg.colors.accent}"
    background = "${cfg.colors.background}"
    key_fill = "${cfg.colors.key_fill}"
    key_border = "${cfg.colors.key_border}"
    key_text = "${cfg.colors.key_text}"
    layer_highlight = "${cfg.colors.layer_highlight}"
    dim_text = "${cfg.colors.dim_text}"

    [layout]
    hash_id = "${cfg.layout.hash_id or "dPWwD6"}"
    keyboard = "${cfg.layout.keyboard}"
    layout_macro = "${cfg.layout.layout_macro}"

    [cache]
    dir = "${cfg.cache.dir}"

    [logging]
    db_path = "${cfg.logging.db_path}"
    socket_path = "${cfg.logging.socket_path}"
  '';

in
  writeText "voyager-config.toml" tomlContent
