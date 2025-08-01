{ pkgs, config, ... }: {
  imports = [ ./hardware-configuration.nix ./disko-config.nix ];

  hardware.opengl.enable = true;
  hardware.opengl.driSupport32Bit = true;
  modules = {
    hostName = "nixtop";
    peripherals = {
      enable = true;
      obs.enable = true;
      scarlettRite.enable = true;
    };
  };

  hardware.nvidia = {
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  environment.systemPackages = [
    pkgs.firefox
    pkgs.wineWowPackages.stable
    pkgs.dxvk
    pkgs.vulkan-tools
    pkgs.cdrtools
  ];

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono pkgs.font-awesome ];
  services.postgresql.enable = true;
  networking.extraHosts = ''
    172.19.0.2 login.gw.local
  '';

  system.stateVersion = "24.05";
}
