{
  pkgs,
  inputs,
  ...
}:
let
  otd-package = (pkgs.opentabletdriver.overrideAttrs { src = pkgs.fetchFromGitHub { owner = "DADA30000"; repo = "OpenTabletDriver"; rev = "5e59bf1ddb69cecf8df0e3c4be8013af9a51a349"; hash = "sha256-iZxfT7ANkkZPe3Y3SUXHuOdLzsnGz6OLn7O4df16Xgc="; }; });
  user = "ehnis";
  user-hash = "$y$j9T$EdzvK4wCXlFTLQYN/LUFJ/$iAJ1pjZ3tT7Uq.mf59cgdyntO4sLhsVA7XDwfEYaPu/";
in
{
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "lublujisn78@gmail.com";
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
  ];

  systemd.services.lactd = {

    enable = true;

    wantedBy = [ "multi-user.target" ];

    serviceConfig = {

      ExecStart = "${pkgs.lact}/bin/lact daemon";

      #ExecStartPre = "${pkgs.coreutils-full}/bin/sleep 10";

      Restart = "always";

      Nice = -10;

    };

  };

  programs.ydotool.enable = true;

  # Disable annoying firewall
  networking.firewall.enable = false;

  # Enable singbox proxy to my XRay vpn
  singbox.enable = true;

  # Run non-nix apps
  programs.nix-ld.enable = true;

  #boot.crashDump.enable = true;

  # Enable RAM compression
  zramSwap.enable = true;
  zramSwap.memoryPercent = 12;

  # Enable ALVR
  programs.alvr.enable = true;
  programs.alvr.openFirewall = true;

  # Enable stuff in /bin and /usr/bin
  services.envfs.enable = true;

  # Enable IOMMU
  boot.kernelParams = [ "iommu=pt" ];

  # Enable some important system zsh stuff
  programs.zsh.enable = true;

  # Enable portals
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  xdg.portal.config.common.default = "*";

  # Enable OpenTabletDriver
  hardware.opentabletdriver.enable = true;
  hardware.opentabletdriver.package = otd-package;

  # Places /tmp in RAM
  boot.tmp.useTmpfs = true;

  # Use mainline (or latest stable) kernel instead of LTS kernel
  #boot.kernelPackages = pkgs.linuxPackages_testing;
  boot.kernelPackages = pkgs.linuxPackages_cachyos;
  #chaotic.scx.enable = true;

  # Enable SysRQ
  boot.kernel.sysctl."kernel.sysrq" = 1;

  # Restrict amount of annoying cache
  boot.kernel.sysctl."vm.dirty_bytes" = 50000000;
  boot.kernel.sysctl."vm.dirty_background_bytes" = 50000000;

  # Adds systemd to initrd (speeds up boot process a little, and makes it prettier)
  boot.initrd.systemd.enable = true;

  # Disable usual coredumps (I hate them)
  security.pam.loginLimits = [
    {
      domain = "*";
      item = "core";
      value = "0";
    }
  ];

  # Enable systemd coredumps
  systemd.coredump.enable = false;

  # Enable generation of NixOS documentation for modules (slows down builds)
  documentation.nixos.enable = false;

  # Enable systemd-networkd for internet
  #systemd.network.wait-online.enable = false;
  #boot.initrd.systemd.network.enable = true;
  #systemd.network.enable = true;
  #networking.useNetworkd = true;

  # Enable dhcpcd for using internet using ethernet cable
  #networking.dhcpcd.enable = true;

  # Enable NetworkManager
  networking.networkmanager.enable = true;

  # Allow making users through useradd
  users.mutableUsers = true;

  # Enable WayDroid
  virtualisation.waydroid.enable = false;

  # Autologin
  services.getty.autologinUser = user;

  # Enable russian anicli
  anicli-ru.enable = false;

  # Enable DPI (Deep packet inspection) bypass
  zapret.enable = false;

  # Enable replays
  replays.enable = true;

  # Enable startup sound on PC speaker (also plays after rebuilds)
  startup-sound.enable = false;

  # Enable zerotier
  zerotier.enable = false;

  # Enable spotify with theme
  spicetify.enable = true;

  # Enable mlocate (find files on system quickly)
  mlocate.enable = true;

  virtualisation.vmVariant = {

    # Set options for vm that is built using nixos-rebuild build-vm
    systemd.user.services.mpvpaper.enable = false;
    virtualisation = {
      qemu.options = [
        "-display sdl,gl=on"
        "-device virtio-vga-gl"
        "-enable-kvm"
        "-audio driver=sdl,model=virtio"
      ];
      cores = 6;
      diskSize = 1024 * 8;
      msize = 16384 * 16;
      memorySize = 1024 * 4;
    };

  };

  flatpak = {

    # Enable system flatpak
    enable = true;

    # Packages to install from flatpak
    packages = [
      {
        flatpakref = "https://vixalien.github.io/muzika/muzika.flatpakref";
        sha256 = "0skzklwnaqqyqj0491dpf746hzzhhxi5gxl1fwb1gyy03li6cj9p";
      }
    ];

  };

  fonts = {

    # Enable some default fonts
    enableDefaultPackages = true;

    # Add some fonts
    packages = with pkgs; [
      noto-fonts
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];

  };

  users.users."${user}" = {

    # Marks user as real, human user
    isNormalUser = true;

    # Sets password for this user using hash generated by mkpasswd
    hashedPassword = user-hash;

    extraGroups = [
      "wheel"
      "uinput"
      "mlocate"
      "nginx"
      "input"
      "kvm"
      "ydotool"
      "adbusers"
      "video"
      "corectrl"
    ];

  };

  nix.settings = {

    # Deduplicates stuff in /nix/store
    auto-optimise-store = true;

    # Enable Hyprland cache
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];

    # Enable flakes
    experimental-features = [
      "nix-command"
      "flakes"
    ];

  };

  obs = {

    # Enable OBS
    enable = true;

    # Enable virtual camera
    virt-cam = true;

  };

  # Enable nvidia stuff
  nvidia.enable = false;

  amdgpu = {

    # Enable AMDGPU stuff
    enable = true;

    # Enable OpenCL and ROCm
    pro = false;

  };

  my-services = {

    # Enable automatic Cloudflare DDNS
    cloudflare-ddns.enable = false;

    nginx = {

      # Enable nginx
      enable = false;

      # Enable my goofy website
      website.enable = false;

      # Enable nextcloud
      nextcloud.enable = false;

      # Website domain
      hostName = "sanic.space";

    };

  };

  disks = {

    # Enable base disks configuration (NOT RECOMMENDED TO DISABLE, DISABLING IT WILL NUKE THE SYSTEM IF THERE IS NO ANOTHER FILESYSTEM CONFIGURATION)
    enable = true;

    # Enable system compression
    compression = true;

    second-disk = {

      # Enable additional disk (must be btrfs)
      enable = false;

      # Enable compression on additional disk
      compression = true;

      # Filesystem label of the partition that is used for mounting
      label = "Games";

      # Which subvolume to mount
      subvol = "games";

      # Path to a place where additional disk will be mounted
      path = "/home/${user}/Games";

    };

    swap = {

      file = {

        # Enable swapfile
        enable = false;

        # Path to swapfile
        path = "/var/lib/swapfile";

        # Size of swapfile in MB
        size = 16 * 1024;

      };

      partition = {

        # Enable swap partition
        enable = true;

        # Label of swap partition
        label = "swap";

      };

    };

  };

  environment = {

    pathsToLink = [ "/share/zsh" ];

    variables = {
      GTK_THEME = "Fluent-Dark";
      ENVFS_RESOLVE_ALWAYS = "1";
      MOZ_ENABLE_WAYLAND = "1";
      TERMINAL = "kitty";
      EGL_PLATFORM = "wayland";
      MOZ_DISABLE_RDD_SANDBOX = "1";
      NIXPKGS_ALLOW_UNFREE = "1";
    };

    systemPackages =
      with pkgs;
      [
        pyright
        lsd
        gamescope
        kdiskmark
        nixfmt-rfc-style
        gdb
        gdu
        gcc
        nixd
        nodejs
        yarn
        ccls
        (firefox-bin.override {
          nativeMessagingHosts = [ inputs.pipewire-screenaudio.packages.${pkgs.system}.default ];
        })
        wget
        git-lfs
        git
        killall
        gamemode
        screen
        unrar
        android-tools
        zip
        jdk23
        mpv
        nix-index
        remmina
        telegram-desktop
        adwaita-icon-theme
        osu-lazer-bin
        steam
        prismlauncher
	rpcs3
	krita
	beatsabermodmanager
	nemo-with-extensions
	nemo-fileroller
	alvr
	kdenlive
        cached-nix-shell
        nvtopPackages.amd
        qbittorrent
        pavucontrol
        wl-clipboard
        bottles
        vesktop
        networkmanager_dmenu
        neovide
        comma
        lact
        libreoffice
        qalculate-gtk
        p7zip
        inputs.nix-alien.packages.${system}.nix-alien
        inputs.nix-search.packages.${system}.default
      ]
      ++ (import ../../modules/system/stuff pkgs).scripts;

  };

  boot.loader = {

    efi.canTouchEfiVariables = true;

    systemd-boot.enable = true;

    systemd-boot.memtest86.enable = true;

    timeout = 0;

  };

  #nix.package = pkgs.nixVersions.latest;

  services = {

    printing.enable = true;

    gvfs.enable = true;

    openssh.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      pulse.enable = true;
    };

  };

  security = {

    rtkit.enable = true;

    polkit.enable = true;

  };

  programs = {

    dconf.enable = true;

    adb.enable = true;

    nh.enable = true;

    neovim = {

      defaultEditor = true;

      viAlias = true;

      vimAlias = true;

      enable = true;

    };

  };

  xdg.terminal-exec = {

    enable = true;

    settings = {

      default = [
        "kitty.desktop"
      ];

    };

  };

  users.defaultUserShell = pkgs.zsh;

  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "ru_RU.UTF-8";

  console = {

    earlySetup = true;

    font = "${pkgs.terminus_font}/share/consolefonts/ter-k16n.psf.gz";

    keyMap = "ru";

  };

  system.stateVersion = "23.11";

}
