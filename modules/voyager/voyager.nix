{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.voyager;

  voyager-pkg = inputs.janeway.packages.${pkgs.system}.default;

  getScheme = default:
    if cfg.colors.accent != "" then cfg.colors
    else if config ? scheme then {
      accent = config.scheme.base0C or "83c092";
      background = config.scheme.base00 or "272e33";
      key_fill = config.scheme.base01 or "2e383c";
      key_border = config.scheme.base02 or "414b50";
      key_text = config.scheme.base05 or "d3c6aa";
      layer_highlight = config.scheme.base0D or "7fbbb3";
      dim_text = config.scheme.base03 or "859289";
    }
    else default;

  defaultColors = {
    accent = "83c092";
    background = "272e33";
    key_fill = "2e383c";
    key_border = "414b50";
    key_text = "d3c6aa";
    layer_highlight = "7fbbb3";
    dim_text = "859289";
  };

  resolvedColors = getScheme defaultColors;

  config-toml = pkgs.callPackage ./config.nix {
    overlay = cfg.overlay;
    layout = {
      hash_id = cfg.layout.hash_id;
      keyboard = cfg.layout.keyboard;
      layout_macro = cfg.layout.layout_macro;
    };
    colors = resolvedColors;
    cache = cfg.cache;
    logging = cfg.logging;
  };
in
{
  options.voyager = lib.mkOption {
    default = {};
    type = lib.types.submodule {
      options = {
        enable = lib.mkEnableOption "voyager keyboard overlay and keylogger";

        overlay = {
          width = lib.mkOption {
            type = lib.types.int;
            default = 480;
          };
          height = lib.mkOption {
            type = lib.types.int;
            default = 220;
          };
          font_size = lib.mkOption {
            type = lib.types.int;
            default = 10;
          };
          label_mode = lib.mkOption {
            type = lib.types.enum [ "short" "long" ];
            default = "short";
          };
          margin = lib.mkOption {
            type = lib.types.int;
            default = 0;
          };
        };

        layout = {
          hash_id = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          keyboard = lib.mkOption {
            type = lib.types.str;
            default = "voyager";
          };
          layout_macro = lib.mkOption {
            type = lib.types.str;
            default = "LAYOUT_voyager";
          };
        };

        colors = {
          accent = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "accent color (leave empty to use theme scheme)";
          };
          background = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          key_fill = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          key_border = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          key_text = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          layer_highlight = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
          dim_text = lib.mkOption {
            type = lib.types.str;
            default = "";
          };
        };

        cache = {
          dir = lib.mkOption {
            type = lib.types.str;
            default = "~/.local/share/voyager/cache";
          };
        };

        logging = {
          db_path = lib.mkOption {
            type = lib.types.str;
            default = "~/.local/share/voyager/keylog.duckdb";
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.etc."voyager/config.toml".source = config-toml;
    environment.systemPackages = [ voyager-pkg ];
    users.users.ixxie.extraGroups = [ "input" ];

    systemd.user.services.voyager-logger = {
      description = "voyager keyboard event logger";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "keymapp.service" ];
      environment.RUST_LOG = "voyager_logger=debug,info";
      serviceConfig = {
        ExecStart = "${voyager-pkg}/bin/voyager-logger";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };

    systemd.user.services.keymapp = {
      description = "ZSA Keymapp (provides gRPC socket for live layer sync)";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      environment.GDK_BACKEND = "x11";
      serviceConfig = {
        # Run inside Xvfb so keymapp's window renders to a virtual framebuffer
        # and never appears in the user's compositor. USB + gRPC still work.
        ExecStart = ''${pkgs.xvfb-run}/bin/xvfb-run --auto-servernum --server-args="-screen 0 800x600x24" ${pkgs.keymapp}/bin/keymapp'';
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}
