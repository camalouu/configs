{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  imports = [
      ./hardware-configuration.nix
      <home-manager/nixos> 
  ];

  # PACKAGES
  environment.systemPackages = with pkgs; [
    home-manager

    openssl

    aria2
    unstable.yt-dlp

    unstable.telegram-desktop
    # Network tools
    wget
    curl
    hurl
    xh
    bandwhich
    termshark
    rustscan
    
    # Development
    gh
    git
    lazygit
    lazydocker
    unstable.github-copilot-cli
    unstable.zed-editor
    jdk
    maven
    helix
    redpanda
    # python3
    (python3.withPackages (ps: with ps; [ matplotlib pandas ]))
    amp

    #node
    nodejs_24

    # c/c++
    gcc
    gdb
    gnumake
    cmake

    # rust/go
    go
    rustc
    cargo
    rustfmt
    rust-analyzer
    clippy
    
    # Terminal utilities
    ripgrep
    fd
    fzf
    alacritty
    zellij
    dust
    duf
    tldr
    procs
    lsd
    glow
    bat
    zoxide
    unstable.yazi
    jq
    unzip
    bottom
    xclip
    stow
    azure-cli
    mosquitto
    sqlite
    
    # Browsers
    chromium
    
    # Media
    mpv
    # clapper #  cant configure subtitles
    # amberol #  cant configure audio speed
    gaphor
    typst
    thunderbird
    vlc
    
    # GNOME
    gnome-tweaks
    gnomeExtensions.paperwm
    gnomeExtensions.run-or-raise
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.vitals
    gnomeExtensions.blur-my-shell
    mission-center
    gitg
    meld
    apostrophe


    xdg-desktop-portal-termfilechooser
    
    # Applications
    unstable.dialect
    speedcrunch
    
    # Keyboard tools
    qmk
    dos2unix
    via

    # nix things, lsp
    nixd
    nil

    # hardware design tools
    spike
    coreboot-toolchain.riscv
    # pkgs.pkgsCross.riscv32.buildPackages.gcc
    verilator
    elfutils 
  ];

  environment.gnome.excludePackages = with pkgs; [
    totem
    geary
    decibels
    epiphany
    showtime
    simple-scan
    yelp
    gnome-text-editor
    gnome-console
    gnome-contacts
    gnome-maps
    gnome-music
    gnome-connections
    gnome-tour
    gnome-system-monitor
  ];

  # SYSTEM
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  networking.hostName = "camalouu";
  networking.networkmanager.enable = true;
  networking.firewall = {
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ]; # for kde connect
    allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  };
  
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_TIME = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
  };
  
  system.stateVersion = "25.05";

  # NIX SETTINGS
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };

  # CONSOLE
  console = {
    font = "ter-v32n";
    packages = [ pkgs.terminus_font ];
    useXkbConfig = true;
  };

  # FONTS
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];
  services.vnstat.enable = true;
  # DISPLAY SERVER & DESKTOP
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.gnome.enable = true;
    # xkb.options = "ctrl:nocaps,compose:ralt";
    xkb.options = "compose:ralt";
    excludePackages = [ pkgs.xterm ];
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  boot.blacklistedKernelModules = [ "nouveau" ];

  # NVIDIA
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    powerManagement.enable = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # AUDIO
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  # SERVICES
  services.gnome.gnome-keyring.enable = true;

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  services.logind.lidSwitch = "ignore";

  # xdg.portal = {
  #   enable = true;
  #
  #   config = {
  #     preferred = {
  #       "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
  #     };
  #   };
  #
  # };

  services.tailscale.enable = true;

  # HARDWARE
  hardware.keyboard.qmk.enable = true;

  # PROGRAMS
  programs.firefox = {
    enable = true;
    preferences = {
      "widget.use-xdg-desktop-portal.file-picker" = 1;
    };
  };
  
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.dconf.enable = true;

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  programs.nix-ld = {
    enable = true;
    libraries = [ pkgs.zlib pkgs.openssl ];
  };

  programs.zsh = {
    enable = true;
    enableCompletion = false;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "lsd -la";
      ls = "lsd";
      lg = "lazygit";
      gst = "git status";
      s = "sudo nixos-rebuild switch";
      sup = "sudo nixos-rebuild switch --upgrade";
      b = "sudo nixos-rebuild build";
      ns = "nix-shell";
      z = "zellij";
    };
  };

  # ENVIRONMENT
  # environment.variables = {
  #   EDITOR = "nvim";
  # };

  virtualisation.docker = {
    enable = true;
  };

  # USER
  users.users.viktor = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "docker"  "input" "uinput" ];
    # extraGroups = [ "wheel" "video" "audio" "networkmanager" ];
    shell = pkgs.zsh;
  };

  nix.settings.trusted-users = [ "root" "viktor" ];

    systemd.services.immich = {
      description = "Immich Docker Compose";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "yes";
        WorkingDirectory = "/mnt/ssd/immich-app";
        ExecStart = "${pkgs.docker}/bin/docker compose up -d";
        ExecStop = "${pkgs.docker}/bin/docker compose down";
        TimeoutStartSec = 0;
      };
    };

    systemd.services.nvidia-clocks = {
      description = "Set NVIDIA GPU clock speed and persistence";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-modules-load.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "nvidia-clocks" ''
          nvidia-smi -pm 1
          nvidia-smi -lgc 1410,2100
        ''}";
      };
      path = [ pkgs.linuxPackages.nvidia_x11 ];
    };

    nixpkgs.config.allowUnfree = true;
    home-manager.useGlobalPkgs = true;
    home-manager.users.viktor = { pkgs, ... }: {
      home.stateVersion = "25.05";
      # home.packages = with pkgs; [ spotify ];
    };

    services.kanata = {
          enable = true;
          keyboards = {
            default = {
              devices = [
                "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
              ];
              extraDefCfg = ''
                process-unmapped-keys yes
                delegate-to-first-layer yes
              '';
              config = ''
                (defsrc
                  caps  a s d f   h j k l scln
                  n m , .
                  lmet lalt spc
                  u i
                  [ ]
                )

                (defchords combos 50
                  (u)   u
                  (i)   i
                  (u i) C-bspc
                )

                (defalias
                  left_shift    (tap-hold-release 200 200 d lsft)
                  left_ctrl    (tap-hold-release 200 200 f lctl)

                  right_ctrl    (tap-hold-release 200 200 j rctl)
                  right_shift    (tap-hold-release 200 200 k rsft)

                  spc_mod  (tap-hold-release 200 200 spc (layer-toggle nav))

                  u_ch     (chord combos u)
                  i_ch     (chord combos i)
                )

                (deflayer base
                  esc   _ _ @left_shift @left_ctrl   _ @right_ctrl @right_shift _ _
                  _ _ _ _
                  lalt lmet @spc_mod
                  @u_ch @i_ch
                  [ ]
                )

                (deflayer nav
                  _     _ _ _ _   left down up rght _
                  home pgdn pgup end
                  _ _ _
                  _ _
                  vold volu
                )
              '';
            };
          };
        };
  hardware.uinput.enable = true;
}
