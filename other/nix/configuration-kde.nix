{ config, lib, pkgs, ... }:
{
  imports =
    [ 
      ./hardware-configuration.nix
    ];
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  networking.hostName = "camalouu";
  networking.networkmanager.enable = true;
  
  time.timeZone = "Europe/Berlin";
  
  console = {
    font = "ter-v32n";
    packages = [ pkgs.terminus_font ];
    useXkbConfig = true;
  };
  
  # X11 keyboard config (applies to GNOME/Wayland too)
  # services.xserver.enable = true;
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "ctrl:nocaps,compose:ralt";
  
  # gnome
  # services.displayManager.gdm.enable = true;
  # services.desktopManager.gnome.enable = true;
  
  # GNOME extensions
  environment.systemPackages = with pkgs; [
    kdePackages.karousel
    xclip
    gnomeExtensions.paperwm
    gnomeExtensions.run-or-raise
    git
    lsd
    neovim
    wget
    alacritty
    ripgrep
    zoxide
    yazi
    fd
    wl-clipboard
  ];
  
  # PaperWM configuration via dconf
  # programs.dconf.profiles.user.databases = [{
  #   settings = {
  #     "org/gnome/shell" = {
  #       enabled-extensions = [
  #         "paperwm@paperwm.github.com"
  #         "run-or-raise@edvard.cz"
  #       ];
  #     };
  #
  #     "org/gnome/shell/extensions/paperwm" = {
  #       show-window-position-bar = false;
  #     };
  #
  #     "org/gnome/shell/extensions/paperwm/keybindings" = {
  #       switch-left = ["<Super>h"];
  #       switch-right = ["<Super>l"];
  #     };
  #   };
  # }];
  
  # Enable Wayland and niri
  # programs.niri.enable = true;
  
  # XDG portal for Wayland
  # xdg.portal = {
    # enable = true;
    # extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    # config.common.default = "*";
  # };
  
   # X11 with Plasma 6
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "plasmax11";
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.options = "eurosign:e,ctrl:nocaps,compose:ralt";
  # services.xserver.videoDrivers = [ "nvidia" ];
  # Sound
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  
  # NVIDIA
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  
  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    powerManagement.enable = true;
    # powerManagement.finegrained = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    
    prime = {
      sync.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  
  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
  ];
  
  # User
  users.users.viktor = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
      zed-editor
      chromium
      # waybar
      # mako
      # fuzzel
      # swaylock
      # swayosd
    ];
    shell = pkgs.zsh;
  };
  
  programs.firefox.enable = true;
  
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
      
      # Keybindings
      bindkey '^[[3;5~' kill-word
    '';
  };
  
  nixpkgs.config.allowUnfree = true;
  
  # Default editor
  environment.variables.EDITOR = "nvim";
  
  system.stateVersion = "25.11";
}
