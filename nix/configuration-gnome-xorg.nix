{ config, lib, pkgs, ... }:
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };
in
{
  imports = [ ./hardware-configuration.nix ];
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
    unstable.yazi
    neovim
    firefox
    chromium
    unstable.zed-editor
    mpv
    xclip
    jq
    unzip
    bottom
    gnome-tweaks
    touchegg
    gnomeExtensions.paperwm
    gnomeExtensions.run-or-raise
  ];
  # BOOT & NETWORKING
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.kernelParams = [ "nvidia.NVreg_EnableGpuFirmware=0" ];
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
  services.gnome.gnome-keyring.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
  programs.nix-ld = {
    enable = true;
    libraries = [ pkgs.zlib pkgs.openssl ];
  };
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };
  # GNOME Xorg
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
    displayManager.gdm = {
      enable = true;
      wayland = false;
    };
    desktopManager.gnome.enable = true;
  };
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
  };
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = ["nix-command"];
  system.stateVersion = "25.05";
}
