{ config, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  imports = [ ./hardware-configuration.nix ];

  # PACKAGES
  environment.systemPackages = with pkgs; [
    # Network tools
    wget
    curl
    hurl
    
    # Development
    gh
    git
    lazygit
    unstable.zed-editor
    
    # Terminal utilities
    ripgrep
    fd
    fzf
    alacritty
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
    
    # Browsers
    chromium
    
    # Media
    mpv
    clapper
    amberol
    gaphor
    
    # GNOME
    gnome-tweaks
    gnomeExtensions.paperwm
    gnomeExtensions.run-or-raise
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.vitals
    gnomeExtensions.blur-my-shell
    mission-center
    # ulauncher
    mailspring
    gitg
    meld

    xdg-desktop-portal-termfilechooser
    
    # Applications
    dialect
    speedcrunch
    
    # Keyboard tools
    qmk
    dos2unix
    via

    # nix things, lsp
    nixd
    nil

    # hardware design tools
    coreboot-toolchain.riscv
    # pkgs.pkgsCross.riscv32.buildPackages.gcc
    verilator
    elfutils 
  ];

  environment.gnome.excludePackages = with pkgs; [
    totem
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


  boot.blacklistedKernelModules = [ "nouveau" ];
  
  networking.hostName = "camalouu";
  networking.networkmanager.enable = true;
  networking.firewall = {
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  };
  
  time.timeZone = "Europe/Berlin";
  
  system.stateVersion = "25.05";

  # NIX SETTINGS
  nixpkgs.config.allowUnfree = true;
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

  # DISPLAY SERVER & DESKTOP
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.gnome.enable = true;
    xkb.options = "ctrl:nocaps,compose:ralt";
    excludePackages = [ pkgs.xterm ];
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

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
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "lsd -la";
      ls = "lsd";
      lg = "lazygit";
      gst = "git status";
      s = "sudo nixos-rebuild switch";
      b = "sudo nixos-rebuild build";
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
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "docker" ];
    # extraGroups = [ "wheel" "video" "audio" "networkmanager" ];
    shell = pkgs.zsh;
  };

  # services.displayManager.autoLogin.enable = true;
  # services.displayManager.autoLogin.user = "viktor";

  nix.settings.trusted-users = [ "root" "viktor" ];

    # systemd.services.nvidia-force-performance = {
    #   description = "Lock Nvidia GPU clocks to high performance to fix Wayland stutter";
    #   # Ensure this runs after the graphical session is ready
    #   after = [ "display-manager.service" ];
    #   wantedBy = [ "multi-user.target" ];
    #
    #   serviceConfig = {
    #     Type = "oneshot";
    #     # We use a script to run multiple nvidia-smi commands in sequence
    #     # 1. Enable Persistence Mode (-pm 1) to prevent the driver from unloading
    #     # 2. Lock Graphics Clocks (-lgc) to Min: 1500, Max: 2100
    #     ExecStart = pkgs.writeShellScript "nvidia-lock" ''
    #       ${config.hardware.nvidia.package.bin}/bin/nvidia-smi -pm 1
    #       ${config.hardware.nvidia.package.bin}/bin/nvidia-smi -lgc 1500,2100
    #     '';
    #     # Optional: Reset clocks when the service is stopped
    #     ExecStop = "${config.hardware.nvidia.package.bin}/bin/nvidia-smi -rgc";
    #     RemainAfterExit = true;
    #   };
    # };

      # boot.kernelParams = [ 
      #  "nvidia.NVreg_EnableGpuFirmware=0"
      #  "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      #  "nvidia.NVreg_DynamicPowerManagement=0x02" 
      # ];

    # environment.sessionVariables = {
    #     # 1. Force Mutter (Gnome) to not aggressively optimize render times for offloaded screens
    #     # This helps prevents the "stutter" on secondary monitors driven by the dGPU
    #     CLUTTER_PAINT = "disable-dynamic-max-render-time";
    #
    #     # 2. Disable G-Sync/VRR specifically for the Nvidia driver
    #     # This prevents the dGPU from trying to sync to a variable rate that the Intel iGPU can't pass through
    #     __GL_GSYNC_ALLOWED = "0";
    #
    #     # 3. (Optional) Force the browser to use Wayland directly if you haven't already
    #     # MOZ_ENABLE_WAYLAND = "1"; 
    #   };

    # environment.etc."/run/current-system/sw/share/applications/Mailspring.desktop:Name=Mailspring".text = ''
    #     Name=Mailspring
    #     Comment=The best email app for people and teams at work
    #     GenericName=Mail Client
    #     Exec=env GDK_DPI_SCALE=2 /nix/store/w8fmlsmbjrcq86yw28a3civwmvvcj02b-mailspring-1.15.1/bin/mailspring %U
    #     Icon=mailspring
    #     Type=Application
    #     StartupNotify=true
    #     StartupWMClass=Mailspring
    #     Categories=GNOME;GTK;Network;Email;
    #     Keywords=email;internet;
    #     MimeType=x-scheme-handler/mailto;x-scheme-handler/mailspring;
    #     Actions=NewMessage
    # '';

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
}
