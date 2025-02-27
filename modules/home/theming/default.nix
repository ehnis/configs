{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.theming;
in
{
  options.theming = {
    enable = mkEnableOption "Enable theming stuff like cursor theme, icon theme and etc";
  };
  


  config = mkIf cfg.enable {
    home.file = {
      ".themes".source = ../../../stuff/.themes;
      ".config/gtk-4.0/assets".source = ../../../stuff/.themes/Fluent-Dark/gtk-4.0/assets;
      ".config/gtk-4.0/gtk.css".source = ../../../stuff/.themes/Fluent-Dark/gtk-4.0/gtk.css;
      ".config/gtk-4.0/icons".source = ../../../stuff/.themes/Fluent-Dark/gtk-4.0/gtk-dark.css;
      ".config/vesktop/settings".source = ../../../stuff/vesktop/settings;
      ".config/vesktop/settings.json".source = ../../../stuff/vesktop/settings.json;
      ".config/vesktop/themes".source = ../../../stuff/vesktop/themes;
    };
    xdg.desktopEntries.vesktop.settings= {
      Exec = "vesktop --ozone-platform-hint=auto %U";
      Categories = "Network;InstantMessaging;Chat";
      GenericName = "Internet Messenger";
      Icon = "vesktop";
      Keywords = "discord;vencord;electron;chat";
      Name = "Vesktop";
      StartupWMClass = "Vesktop";
      Type = "Application";
    };
    dconf.settings = {
      "org/nemo/preferences" = {
        default-folder-viewer = "icons-view";
        show-hidden-files = true;
        thumbnail-limit = lib.hm.gvariant.mkUint64 68719476736;
      };
      "org/gnome/desktop/interface" = { 
        color-scheme = "prefer-dark"; 
      };
    };
    qt = {
      enable = true;
      platformTheme.name = "gtk3";
    };
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.oreo-cursors-plus;
      name = "oreo_spark_black_bordered_cursors";
      size = 24;
    };
    gtk = {
      enable = true;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
      gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
      iconTheme = {
        name = "Windows-Eleven";
        package = pkgs.morewaita-icon-theme;
      };
      theme.name = "Fluent-Dark";
      font.name = "Noto Sans Medium";
      font.size = 11;
    };
  };
}
