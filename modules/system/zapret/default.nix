{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.zapret;
  
  # Список доменов VRChat
  vrchatHostlist = pkgs.writeText "vrchat-hosts.txt" ''
    vrchat.com
    vrchat.net
    api.vrchat.cloud
    status.vrchat.com
    vrchat.cloud
    pipeline.vrchat.cloud
    assets.vrchat.com
    creators.vrchat.com
    docs.vrchat.com
    wiki.vrchat.com
    vrchat.community
    vrchatassets.com
    vrcdn.live
    vrcdn.video
    vrcdn.cloud
    files.vrchat.cloud
    cdn.vrchat.com
    www.quora.com
  '';

  # Конфигурационный файл zapret
  zapretConfig = pkgs.writeText "zapret-config" ''
    # Основные настройки
    MODE=nfqws
    
    # Порт для прослушивания (tpws)
    TPWS_PORT=988
    
    # Опции для nfqws
    NFQWS_OPT_HTTP="--filter-tcp=80 --hostlist=/opt/zapret/ipset/zapret-hosts-user.txt --dpi-desync=fake,multisplit --dpi-desync-autottl=2 --dpi-desync-fooling=md5sig"
    NFQWS_OPT_HTTPS="--filter-tcp=443 --hostlist=/opt/zapret/ipset/zapret-hosts-user.txt --dpi-desync=multisplit --dpi-desync-split-pos=2,sniext+1 --dpi-desync-split-seqovl=679"
    NFQWS_OPT_QUIC="--filter-udp=443 --hostlist=/opt/zapret/ipset/zapret-hosts-user.txt --dpi-desync=fake --dpi-desync-repeats=6"
    
    # Дополнительные порты из вашей конфигурации
    NFQWS_OPT_EXTRA="--filter-tcp=2053,2083,2087,2096,8443 --filter-udp=19294-19344,50000-50100"
  '';

in
{
  options.zapret = {
    enable = mkEnableOption "Включить обход DPI с помощью Zapret";
  };

  config = mkIf cfg.enable {
    users.users.tpws = {
      isSystemUser = true;
      group = "tpws";
    };
    users.groups.tpws = { };
    
    # Создаем необходимые директории и файлы конфигурации
    system.activationScripts.zapret-setup = {
      text = ''
        mkdir -p /opt/zapret/ipset
        mkdir -p /etc/zapret
        
        cp ${vrchatHostlist} /opt/zapret/ipset/zapret-hosts-user.txt
        
        cp ${zapretConfig} /etc/zapret/config
        
        chown -R tpws:tpws /opt/zapret
        chmod -R 755 /opt/zapret
      '';
    };

    systemd.services.zapret = {
      enable = true;
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      
      path = with pkgs; [
        iptables
        nftables
        ipset
        curl
        gawk
        zapret
      ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "tpws";
        Group = "tpws";
        WorkingDirectory = "/opt/zapret";
        
        ExecStart = "${pkgs.bash}/bin/bash -c 'zapret start'";
        ExecStop = "${pkgs.bash}/bin/bash -c 'zapret stop'";
      };
    };

    services.resolved.enable = false;

    services.dnscrypt-proxy = {
      enable = true;
      settings = {
        server_names = [
          "cloudflare"
          "scaleway-fr" 
          "google"
          "yandex"
        ];
        listen_addresses = [
          "127.0.0.1:53"
          "[::1]:53"
        ];
      };
    };
    
    networking = {
      nameservers = [
        "::1"
        "127.0.0.1"
      ];
      resolvconf.dnsSingleRequest = true;
      firewall = {
        enable = false;
        allowedTCPPorts = [
          22
          80
          443
          53
          988
          2053
          2083
          2087
          2096
          8443
          25565
        ];
        allowedUDPPorts = [
          53
          443
          22
          80
          53
          988
          25565
        ];
      };
    };
  };
}
