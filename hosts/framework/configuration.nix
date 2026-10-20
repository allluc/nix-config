{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./disks.nix
    ../../modules/nixos
    inputs.tiberius-nix.nixosModules.default
  ];
  modules = {
    hostName = "alucas";
    grub = false;
    peripherals = {
      enable = true;
      scarlettRite.enable = true;
    };
  };
  boot.resumeDevice = "/dev/mapper/crypted";
  # Get offset with: sudo btrfs inspect-internal map-swapfile -r /.swapvol/swapfile
  boot.kernelParams = [
    "resume_offset=533760"
    "amdgpu.dcdebugmask=0x410"
    "amdgpu.sg_display=0"
    "amdgpu.abmlevel=0"
  ];

  services.tlp.enable = lib.mkForce false;
  modules.powerProfiles.autoSwitch = true;
  # stable virtual keyboard for push-to-talk (see modules/nixos/peripherals)
  modules.peripherals.keyd.enable = true;
  modules.virtualization.libvirt.enable = true;
  services.fwupd.enable = true;
  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.font-awesome
  ];
  hardware = {
    enableRedistributableFirmware = true;
    keyboard.zsa.enable = true;
  };

  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=US
  '';

  services.openssh.enable = true;
  services.clamav = {
    clamonacc.enable = true;
    daemon.settings = {
      OnAccessIncludePath = [
        "/run/media"
        "/media"
      ];
      OnAccessPrevention = true;
    };
  };
  systemd.tmpfiles.rules = [
    "d /run/media 0755 root root -"
    "d /media 0755 root root -"
  ];
  tiberius = {
    hostName = "alucas";
    tailscale.operatorUser = "alucas";
    endpointVerification.browsers = [ "chrome" ];
    cmmc.autoUpgrade.flake = "git+ssh://git@github.com/allluc/nix-config#framework";
  };

  system.stateVersion = "26.05";
}
