{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.obs;
in
{
  options.obs = {
    enable = mkEnableOption "Enable OBS";
    virt-cam = mkEnableOption "Enable virtual camera";
  };
  


  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.obs-studio ];
    boot = mkIf cfg.virt-cam {
      extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
      extraModprobeConfig = ''
        options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
      '';
      kernelModules = [
        "v4l2loopback"
      ];
    };
  };
}
