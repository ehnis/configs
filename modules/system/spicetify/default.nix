{ config, lib, pkgs, inputs, ... }:
with lib;
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  cfg = config.spicetify;
in
{
  options.spicetify = {
    enable = mkEnableOption "Enable spotify with theme";
  };
  

  imports = [ inputs.spicetify-nix.nixosModules.default ];
  config = mkIf cfg.enable {
    programs.spicetify = {
      enable = true;
      enabledExtensions = with spicePkgs.extensions; [
        adblock
        hidePodcasts
        shuffle
      ];
      theme = spicePkgs.themes.starryNight;
      colorScheme = "base";
    };
  };
}
