{ config, lib, pkgs, ... }:
{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # --- BOOT & NETWORKING ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "camalouu";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Berlin";

  # --- CONSOLE ---
  console = {
    font = "ter-v32n";
    packages = [ pkgs.terminus_font ];
    useXkbConfig = true;
  };

  # --- NIRI & WAYLAND CONFIGURATION ---
  programs.niri.enable = true;

  # --- NVIDIA CONFIGURATION (Wayland Mode) ---
  hardware.graphics = {
    enable = true;
  };

  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   open = true;
  #   nvidiaSettings = true;
  #   package = config.boot.kernelPackages.nvidiaPackages.stable;
  #
  #   powerManagement.enable = false;
  #   powerManagement.finegrained = false; 
  #
  #   prime = {
  #     sync.enable = true;
  #     # offload.enable = true;
  #     # offload.enableOffloadCmd = true;
  #     intelBusId = "PCI:0:2:0";
  #     nvidiaBusId = "PCI:1:0:0";
  #   };
  # };
  #
  #   boot.kernelParams = [ 
  #     "nvidia.NVreg_EnableGpuFirmware=0"
  #     "nouveau.modeset=0"
  #   ];
  #
  #   boot.blacklistedKernelModules = [ "nouveau" ];
  #
  #   services.xserver.videoDrivers = [ "nvidia" ];

  # --- ENVIRONMENT VARIABLES ---
  environment.variables = {
    EDITOR = "nvim";
    # Force Electron apps (Code, Discord, Chrome) to run on Wayland
    # NIXOS_OZONE_WL = "1";
    # Firefox Wayland
    # MOZ_ENABLE_WAYLAND = "1";
    # Nvidia VA-API
    # NVD_BACKEND = "direct";
    # LIBVA_DRIVER_NAME = "nvidia";
    # MOZ_DISABLE_RDD_SANDBOX = "1"; 
    # __GL_GSYNC_ALLOWED = "0"; 
    # __GL_VRR_ALLOWED = "0";
    # Force browsers to ignore vsync limits if they persist
    # vblank_mode = "0";
  };

  # --- PACKAGES ---
  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];

  environment.systemPackages = with pkgs; [
    alacritty
    wget
    git
    gh
    mpv
    ripgrep
    nautilus
    fd
    lsd
    zoxide
    yazi
    neovim
    firefox
    zed-editor
    chromium
    wl-clipboard
    fuzzel
    gnome-keyring
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    kdePackages.polkit-kde-agent-1
    xwayland-satellite
    mako
    waybar
    swayosd
  ];

  # --- FIREFOX ---
  programs.firefox = {
    enable = true;
    preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
      "media.hardware-video-decoding.force-enabled" = true;
      "widget.dmabuf.force-enabled" = true;
    };
  };

  # --- USER & SHELL ---
  users.users.viktor = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" ];
    shell = pkgs.zsh;
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

    interactiveShellInit = ''
      # Yazi cd function
      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }

      # Zoxide
      eval "$(zoxide init --cmd=cd zsh)"

      # Git prompt
      autoload -Uz vcs_info
      precmd() { vcs_info }
      setopt prompt_subst
      zstyle ':vcs_info:git:*' formats ' %F{magenta}(%b)%f'
      PROMPT='%F{yellow}%1~%f''${vcs_info_msg_0_} ➜ '

      bindkey '^[[3;5~' kill-word
    '';
  };

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";
}
