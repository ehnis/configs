{ config, lib, inputs, pkgs, options, user, hostname, ... }:
let
  fileroller = "org.gnome.FileRoller.desktop";
  long-script = "${pkgs.beep}/bin/beep -l 100 -f 15804.2656402 -n -l 25 -f 19.4454364826 -n -l 25 -f 123.470825314 -n -l 50 -f 554.365261954 -n -l 75 -f 138.591315488 -n -l 75 -f 1108.73052391 -n -l 50 -f 19.4454364826 -n -l 75 -f 783.990871963 -n -l 50 -f 19.4454364826 -n -l 75 -f 698.456462866 -n -l 50 -f 195.997717991 -n -l 25 -f 184.997211356 -n -l 50 -f 1108.73052391 -n -l 75 -f 783.990871963 -n -l 100 -f 138.591315488 -n -l 25 -f 155.563491861 -n -l 150 -f 698.456462866 -n -l 125 -f 195.997717991 -n -l 50 -f 554.365261954 -n -l 25 -f 587.329535835 -n -l 50 -f 138.591315488 -n -l 75 -f 1108.73052391 -n -l 50 -f 19.4454364826 -n -l 75 -f 880.0 -n -l 25 -f 38.8908729653 -n -l 25 -f 19.4454364826 -n -l 75 -f 739.988845423 -n -l 75 -f 220.0 -n -l 75 -f 1108.73052391 -n -l 50 -f 880.0 -n -l 25 -f 19.4454364826 -n -l 75 -f 138.591315488 -n -l 25 -f 123.470825314 -n -l 150 -f 739.988845423 -n -l 125 -f 220.0 -n -l 75 -f 554.365261954 -n -l 50 -f 138.591315488 -n -l 75 -f 1108.73052391 -n -l 25 -f 1046.5022612 -n -l 25 -f 1108.73052391 -n -l 25 -f 19.4454364826 -n -l 50 -f 783.990871963 -n -l 25 -f 830.60939516 -n -l 25 -f 19.4454364826 -n -l 25 -f 622.253967444 -n -l 75 -f 698.456462866 -n -l 50 -f 195.997717991 -n -l 25 -f 155.563491861 -n -l 50 -f 1108.73052391 -n -l 75 -f 783.990871963 -n -l 100 -f 138.591315488 -n -l 25 -f 19.4454364826 -n -l 125 -f 698.456462866 -n -l 150 -f 195.997717991 -n -l 50 -f 622.253967444 -n -l 75 -f 698.456462866 -n -l 75 -f 739.988845423 -n -l 25 -f 19.4454364826 -n -l 25 -f 38.8908729653 -n -l 125 -f 739.988845423 -n -l 100 -f 783.990871963 -n -l 25 -f 19.4454364826 -n -l 75 -f 783.990871963 -n -l 150 -f 880.0 -n -l 50 -f 19.4454364826 -n -l 125 -f 1108.73052391 -n -l 75 -f 261.625565301 -n -l 25 -f 277.182630977 -n -l 25 -f 261.625565301 ";
in
{
  flatpak.packages=[{ appId = "org.vinegarhq.Sober"; origin = "sober"; }];
  flatpak.enable=true;
  #Some servicess
  services = {
    getty.autologinUser = user;
    printing.enable = true;
    gvfs.enable = true;
    openssh.enable = true;
    nextjs-ollama-llm-ui.enable = true;
    ollama = {
      enable = true;
      package = pkgs.ollama;
      openFirewall = true;
    };
    locate = {
      enable = true;
      package = pkgs.mlocate;
      interval = "hourly";
      localuser = null;
    };
    resolved = {
      enable = true;
    };
    dnscrypt-proxy2 = {
      enable = true;
      settings = {
        server_names = [ "cloudflare" "scaleway-fr" "yandex" "google" ];
        listen_addresses = [ "127.0.0.1:53" "[::1]:53" ];
      };
    };
    sunshine = {
      enable = false;
      capSysAdmin = true;
      autoStart = false;
      openFirewall = true;
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = false;
      pulse.enable = true;
      jack.enable = false;
    };
    xserver = {
      xkb.layout = "us,ru";
      xkb.options = "grp:alt_shift_toggle";
      displayManager.startx.enable = true;
      videoDrivers = [ "amdgpu"];
      enable = true;
    };
    snapper = {
      persistentTimer = true;
      configs.server = {
        SUBVOLUME = "/home/${user}/server";
	TIMELINE_LIMIT_YEARLY = 0;
	TIMELINE_LIMIT_WEEKLY = 2;
	TIMELINE_LIMIT_MONTHLY = 1;
	TIMELINE_LIMIT_HOURLY = 24;
	TIMELINE_LIMIT_DAILY = 7;
	TIMELINE_CREATE = true;
	TIMELINE_CLEANUP = true;
      };
    };
  };
  #Some security
  security = {
    pam.loginLimits = [ { domain = "*"; item = "core"; value = "0"; } ];
    rtkit.enable = true;
    polkit.enable = true;
    wrappers.gsr-kms-server = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+ep";
      source = "${pkgs.gpu-screen-recorder}/bin/gsr-kms-server";
    };
    sudo.extraRules = [
      {
        groups = [ "deploy" ];
        commands = [
          {
            command = "/nix/store/*/bin/switch-to-configuration";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/nix-store";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/nix-env";
            options = [ "NOPASSWD" ];
          }
          {
            command = ''/bin/sh -c "readlink -e /nix/var/nix/profiles/system || readlink -e /run/current-system"'';
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/nix-collect-garbage";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
  #Some programs
  programs = {
    dconf.enable = true;
    xwayland.enable = true;
    zsh.enable = true;
    nm-applet.enable = true;
    adb.enable = true;
    firefox.nativeMessagingHosts.ff2mpv = true;
  };
  #Some boot settings
  boot = {
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    blacklistedKernelModules = [ "hid-uclogic" "wacom" ];
    initrd.systemd.enable = true;
    kernel.sysctl."kernel.sysrq" = 1;
    kernelPackages = pkgs.linuxPackages_xanmod_latest; 
    tmp.useTmpfs = true;
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
    '';
    kernelParams = [ 
      "amd_iommu=on" 
      "iommu=pt"
    ];
    kernelModules = [
      "v4l2loopback"
    ];
    loader = {
      efi.canTouchEfiVariables = true;
      #grub = {
      #  enable = true;
      #  efiSupport = true;
      #  device = "nodev";
      #  timeoutStyle = "hidden";
      #};
      systemd-boot = {
        enable = true;
      };
    };
  };
  #Some nix settings
  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
    auto-optimise-store = true;
    substituters = [
      "https://hyprland.cachix.org" 
      "https://nix-gaming.cachix.org" 
      "https://nixpkgs-unfree.cachix.org"
    ];
    trusted-public-keys = [ 
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" 
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" 
      "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs=" 
    ];
    experimental-features = [ 
      "nix-command" 
      "flakes"
    ];
  };
  #Some systemd stuff
  systemd = {
    coredump.enable = false;
    tmpfiles.rules = 
    let
      rocmEnv = pkgs.symlinkJoin {
        name = "rocm-combined";
        paths = with pkgs.rocmPackages; [
          rocblas
          hipblas
          clr
        ];
      };
    in [
      "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
    ];
    services = { 
     zapret = {
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        path = with pkgs; [
          iptables
          ipset
	  nftables
	  	  (zapret.overrideAttrs (prev: {
            installPhase = ''
              ${prev.installPhase}
              touch $out/usr/share/zapret/config
            '';
          }))
          gawk
        ];
        serviceConfig = {
          Type = "forking";
          Restart = "no";
          TimeoutSec = "30sec";
          IgnoreSIGPIPE = "no";
          KillMode = "none";
          GuessMainPID = "no";
          ExecStart = "${pkgs.bash}/bin/bash -c 'zapret start'";
          ExecStop = "${pkgs.bash}/bin/bash -c 'zapret stop'";
	  EnvironmentFile = pkgs.writeText "zapret-environment" ''
            # MODE="tpws"
	    MODE="nfqws"
	    FWTYPE="iptables"
	    MODE_HTTP=1
	    MODE_HTTP_KEEPALIVE=1
	    MODE_HTTPS=1
	    MODE_QUIC=0
	    MODE_FILTER=none
	    DISABLE_IPV6=1
	    INIT_APPLY_FW=1
	    NFQWS_OPT_DESYNC="--dpi-desync=fake,split2 --dpi-desync-fooling=datanoack"
	    #NFQWS_OPT_DESYNC="--dpi-desync=split2"
	    #NFQWS_OPT_DESYNC="--dpi-desync=fake --dpi-desync-ttl=9 --dpi-desync-fooling=md5sig"
            # и прочая конфигурация которую можно получить с помощью nix-shell -p zapret --run blockchec
          '';
        };
      };
      startup-sound = {
        wantedBy = ["sysinit.target"];
        enable = true;
        preStart = "${pkgs.kmod}/bin/modprobe pcspkr";
        serviceConfig = {
          ExecStart = long-script;
        };
      };
    };
    user.services = {
      waybar.serviceConfig.Restart = "always";
      polkit_gnome = {
        path = [pkgs.bash];
	script = ''
	  exec ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1
	'';
	wantedBy = [ "hyprland-session.target" ];
      };
    };
  };
  #Some hardware stuff
  hardware = {
    opentabletdriver = {
      enable = true;
      package = (pkgs.opentabletdriver.overrideAttrs { src = pkgs.fetchFromGitHub { owner = "DADA30000"; repo = "OpenTabletDriver"; rev = "5e59bf1ddb69cecf8df0e3c4be8013af9a51a349"; hash = "sha256-iZxfT7ANkkZPe3Y3SUXHuOdLzsnGz6OLn7O4df16Xgc="; }; });
    };
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
	rocmPackages.clr.icd
      ];
    };
  };
  #Some environment stuff
  environment = {
    variables = {
      QT_STYLE_OVERRIDE = "kvantum";
      GTK_THEME = "Materia-dark";
      XCURSOR_THEME = "Bibata-Modern-Classic";
      MOZ_ENABLE_WAYLAND = "1";
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERMINAL = "kitty";
      XCURSOR_SIZE = "24";
      EGL_PLATFORM = "wayland";
      MOZ_DISABLE_RDD_SANDBOX = "1";
    };
    systemPackages = with pkgs; [
      pyenv
      wget
      git
      obs-studio
      neovim
      osu-lazer-bin
      xclicker
      inotify-tools
      fastfetch
      libsForQt5.kdenlive
      ipset
      hyprshot     
      vscodium
      nemo-with-extensions
      cinnamon-translations
      killall
      ffmpeg
      wl-clipboard
      pulseaudio
      prismlauncher
      nwg-look
      file-roller
      appimage-run
      cliphist
      libnotify
      swappy
      zapret
      bibata-cursors
      ffmpegthumbnailer
      krita
      dotnetCorePackages.sdk_9_0
      gimp
      steam
      screen
      nvtopPackages.full
      gamemode
      moonlight-qt
      desktop-file-utils
      (firefox.override { nativeMessagingHosts = [ inputs.pipewire-screenaudio.packages.${pkgs.system}.default ff2mpv ]; })
      wlogout
      youtube-music
      mpv
      testdisk
      rusty-psn
      rpcs3
      ncmpcpp
      mpd
      neovide
      qbittorrent
      unrar
      pavucontrol
      brightnessctl
      rustdesk-flutter
      mlocate
      imv
      nemo-fileroller
      zip
      jdk21
      myxer
      gpu-screen-recorder-gtk
      gpu-screen-recorder
      snapper
      cached-nix-shell
      clblast
    ] ++ (import ./stuff.nix pkgs).scripts ++ (import ./stuff.nix pkgs).hyprland-pkgs;
  };
  nixpkgs.config.permittedInsecurePackages = [ "freeimage-unstable-2021-11-01" ];
  #And here is some other small stuff
  documentation.nixos.enable = false;
  qt.enable = true;
  xdg.mime.defaultApplications = {
    "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
    "application/x-compressed-tar" = fileroller;
    "application/x-bzip2-compressed-tar" = fileroller;
    "application/x-bzip1-compressed-tar" = fileroller;
    "application/x-tzo" = fileroller;
    "application/x-xz"= fileroller;
    "application/x-lzma-compressed-tar" = fileroller;
    "application/zstd" = fileroller;
    "application/x-7z-compressed" = fileroller;
    "application/x-zstd-compressed-tar" = fileroller;
    "application/x-lzma" = fileroller;
    "application/x-lz4" = fileroller;
    "application/x-xz-compressed-tar" = fileroller;
    "application/x-lz4-compressed-tar" = fileroller;
    "application/x-archive" = fileroller;
    "application/x-cpio" = fileroller;
    "application/x-lzop" = fileroller;
    "application/x-bzip1" = fileroller;
    "application/x-tar" = fileroller;
    "application/x-bzip2" = fileroller;
    "application/gzip" = fileroller;
    "application/x-lzip-compressed-tar" = fileroller;
    "application/x-tarz "= fileroller;
    "application/zip" = fileroller;
    "inode/directory" = "nemo.desktop";
    "text/html" = "firefox.desktop";
    "video/mp4" = "mpv.desktop";
    "audio/mpeg" = "mpv.desktop";
    "audio/flac" = "mpv.desktop";
  };
  users.defaultUserShell = pkgs.zsh;
  nixpkgs.config.allowUnfree = true;
  imports =
    [
      #./my-services.nix
      ./flatpak.nix
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
    ];
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      (nerdfonts.override { fonts = [ "JetBrainsMono" "0xProto" "Hack" ]; })
    ];
    fontconfig = {
      antialias = true;
      cache32Bit = true;
      hinting.enable = true;
      hinting.autohint = true;
    };
  };
  networking.hostName = hostname;
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "ru_RU.UTF-8";
  networking = {
   nameservers = [ "::1" "127.0.0.1" ];
    resolvconf.dnsSingleRequest = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 25565 25566 25585 25575 25555 25568 25576 11434 3000 35099 25595 25545 ];
      allowedUDPPorts = [ 22 80 25565 25566 25585 25575 25555 25568 25576 11434 3000 35099 25595 25545 ];
      };
  };
  console = {
    earlySetup = true;
    font = null;
    useXkbConfig = true;
  };
  users.users."${user}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "uinput" "mlocate" "nginx" "input" "kvm" "adbusers" "vboxusers" "video" "deploy" ];
    openssh.authorizedKeys.keys = [ 
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDOEop30AK3ka7ieej+xhvHAHwvkiGW2uinjF50bDBxt l0lk3k@nixos''
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEQjJreCXvUdgGNVaEAkHHNaoP9zfjrFVsebaq5slIPV root@nixos''
    ];
    packages = with pkgs; [
      tree
    ];
  };
  xdg.portal = { enable = true; extraPortals = [ pkgs.xdg-desktop-portal-hyprland pkgs.xdg-desktop-portal-gtk ]; }; 
  xdg.portal.config.common.default = "*";
  system.stateVersion = "23.11";
  users.users.tpws = {
    isSystemUser = true;
    group = "tpws";
  };
  users.groups.tpws = {};
  nix.package = pkgs.nixVersions.latest;
}
