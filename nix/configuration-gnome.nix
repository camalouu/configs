{ config, lib, pkgs, ... }:
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
    neovim
    unstable.zed-editor
    
    # Terminal utilities
    ripgrep
    fd
    alacritty
    lsd
    zoxide
    unstable.yazi
    jq
    unzip
    bottom
    xclip
    
    # Browsers
    chromium
    
    # Media
    mpv
    
    # GNOME
    gnome-tweaks
    gnomeExtensions.paperwm
    gnomeExtensions.run-or-raise
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.vitals

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
    options = "--delete-older-than 30d";
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

  # HARDWARE
  hardware.keyboard.qmk.enable = true;

  # PROGRAMS
  programs.firefox = {
    enable = true;
    preferences = {
      "widget.use-xdg-desktop-portal.file-picker" = 1;
    };
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
    };
  };

  # ENVIRONMENT
  environment.variables = {
    EDITOR = "nvim";
  };

  # USER
  users.users.viktor = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "networkmanager" ];
    shell = pkgs.zsh;
  };

}
