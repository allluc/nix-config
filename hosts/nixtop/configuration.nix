{ pkgs, ... }: {
  imports = [ ./hardware-configuration.nix ./disko-config.nix ];

  modules = {
    hostName = "nixtop";
    peripherals = {
      enable = true;
      obs.enable = true;
      scarlettRite.enable = true;
    };
  };
  environment.systemPackages = [ pkgs.firefox ];

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono pkgs.font-awesome ];

  networking.extraHosts = ''
    172.19.0.2 login.gw.local
  '';

  system.stateVersion = "24.05";
}
