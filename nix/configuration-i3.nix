{ config, lib, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # BOOT & NETWORKING
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "nvidia.NVreg_EnableGpuFirmware=0" ];
  boot.blacklistedKernelModules = [ "nouveau" ];

  networking.hostName = "camalouu";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Berlin";

  # CONSOLE
  console = {
    font = "ter-v32n";
    packages = [ pkgs.terminus_font ];
    useXkbConfig = true;
  };

  programs.dconf.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  # X11 + i3
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];

    desktopManager = {
      xterm.enable = false;
    };
    
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
      ];
    };
  };

  services.displayManager.defaultSession = "none+i3";

  programs.i3lock.enable = true;

  # NVIDIA
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    powerManagement.enable = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    
    prime = {
      sync.enable = true;
      # offload.enable = true;
      # offload.enableOffloadCmd = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # ENV VARS
  environment.variables = {
    EDITOR = "nvim";
  };

  # FONTS
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];

  # PACKAGES
  environment.systemPackages = with pkgs; [
    wget
    gh
    git
    ripgrep
    fd
    alacritty
    lsd
    zoxide
    yazi
    neovim
    firefox
    chromium
    zed-editor
    xclip
    jq
    psmisc
    feh  # wallpaper
    picom  # compositor
    pulseaudio
    brightnessctl
    dunst        # Notification daemon
    libnotify    # Sends the actual notifications (notify-send)
  ];

  # USER
  users.users.viktor = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" ];
    shell = pkgs.zsh;
  };

  # ZSH
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
      function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
          builtin cd -- "$cwd"
        fi
        rm -f -- "$tmp"
      }

      eval "$(zoxide init --cmd=cd zsh)"

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
