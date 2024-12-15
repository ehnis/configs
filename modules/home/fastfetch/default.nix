{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.fastfetch;
in
{
  options.fastfetch = {
    enable = mkEnableOption "Enable fastfetch config";
    zsh-start = mkEnableOption "Enable fastfetch printing when zsh starts up";
    logo-path = mkOption {
      type = types.path;
      default = ../../stuff/logo.png;
      example = ./logo.png;
      description = "Path to the logo that fastfetch will output";
    };
  };

  config = mkIf cfg.enable {
    programs.zsh.initExtra = mkIf cfg.zsh-start ''
      if ! [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        fastfetch --logo-color-1 'black' --logo-color-2 'green'
      fi
    '';
    programs.fastfetch = {
      enable = true;
      settings = {
        logo = {
          type = "kitty-direct";
          source = cfg.logo-path;
          width = 50;
          height = 20;
        };
        display = {
          separator = " ";
        };
        modules = [
          {
            type = "command";
            key = " ";
            text = "nixos.sh";
          }
          "break"
          {
            type = "cpu";
            key = "╭─";
            keyColor = "green";
          }
          {
            type = "gpu";
            key = "├─󰢮";
            keyColor = "green";
          }
          {
            type = "disk";
            key = "├─";
            keyColor = "green";
          }
          {
            type = "memory";
            key = "├─󰑭";
            keyColor = "green";
          }
          {
            type = "swap";
            key = "├─󰓡";
            keyColor = "green";
          }
          #{
          #  type = "display";
          #  key = "├─󰍹";
          #  keyColor = "green";
          #}
          {
            type = "brightness";
            key = "├─󰃞";
            keyColor = "green";
          }
          {
            type = "battery";
            key = "├─";
            keyColor = "green";
          }
          {
            type = "poweradapter";
            key = "├─";
            keyColor = "green";
          }
          {
            type = "gamepad";
            key = "├─";
            keyColor = "green";
          }
          {
            type = "bluetooth";
            key = "├─";
            keyColor = "green";
          }
          {
            type = "sound";
            key = "├─";
            keyColor = "green";
          }
          {
            type = "shell";
            key = "├─";
            keyColor = "green";
          }
          {
            type = "de";
            key = "├─";
            keyColor = "green";
          }
          {
            type = "wm";
            key = "├─";
            keyColor = "green";
          }
          {
            type = "os";
            key = "├─";
            keyColor = "green";
          }
          {
            type = "kernel";
            key = "├─";
            format = "{1} {2}";
            keyColor = "green";
          }
          {
            type = "uptime";
            key = "╰─󰅐";
            keyColor = "green";
          }
        ];
      };
    };
  };
}
