{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  cfg = config.modules.hyprland.standalone;
  inherit (lib) mkIf mkEnableOption;
  # Graphics-facing Hyprland packages must come from the same nixpkgs as
  # the running system: they load /run/opengl-driver, and Mesa refuses a
  # driver from a different Mesa build.
  sysPkgs = inputs.nixpkgs-system.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  hyprlandOnTty = pkgs.writeShellApplication {
    name = "hyprland-on-tty";
    runtimeInputs = [
      pkgs.procps
      pkgs.systemd
    ];
    text = ''
      # Only on a local text console, not over SSH or inside a desktop.
      [[ "$(tty)" == /dev/tty[0-9]* ]] || exit 0
      [[ -z "''${SSH_CONNECTION:-}" && -z "''${WAYLAND_DISPLAY:-}" && -z "''${DISPLAY:-}" ]] || exit 0

      # Both sessions share one systemd user manager; starting Hyprland
      # restarts graphical-session.target and tears down a running GNOME.
      if pgrep -u "$USER" -x gnome-shell >/dev/null; then
        echo "GNOME is still running: log out of it first, then run start-hyprland."
        exit 0
      fi

      # Not exec: if Hyprland exits or crashes, fall back to this shell
      # instead of a login loop.
      ${config.wayland.windowManager.hyprland.finalPackage}/bin/start-hyprland || true
      systemctl --user unset-environment HYPRLAND_INSTANCE_SIGNATURE
      echo "Hyprland exited. Run start-hyprland to start it again, or 'exit' to log out."
    '';
  };
in
{
  options.modules.hyprland.standalone.enable = mkEnableOption ''
    Install Hyprland from Home Manager, for machines whose NixOS config is
    not built from this flake (so programs.hyprland is unavailable).
    Start it from a TTY with `start-hyprland`'';

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      package = sysPkgs.hyprland;
      portalPackage = sysPkgs.xdg-desktop-portal-hyprland;
    };

    # Home Manager points xdg-desktop-portal at its own portal directory in
    # every session, hiding the system's portals: add GTK for Hyprland's
    # file chooser, and GNOME's so the GNOME session keeps working.
    xdg.portal = {
      extraPortals = [
        sysPkgs.xdg-desktop-portal-gtk
        sysPkgs.xdg-desktop-portal-gnome
      ];
      config = {
        hyprland = {
          default = [
            "hyprland"
            "gtk"
          ];
          "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        };
        gnome.default = [
          "gnome"
          "gtk"
        ];
      };
    };

    programs.hyprlock = {
      package = sysPkgs.hyprlock;
      # No /etc/pam.d/hyprlock without the NixOS module; PAM's fallback
      # denies every password, which would make unlocking impossible.
      settings.auth."pam:module" = "login";
    };

    services.hyprpaper.package = sysPkgs.hyprpaper;

    home.sessionVariables.NIXOS_OZONE_WL = "1";

    # GDM can't offer this session, so start Hyprland from a text-console
    # login instead.
    programs.bash.profileExtra = ''
      ${hyprlandOnTty}/bin/hyprland-on-tty
    '';
    programs.zsh.profileExtra = ''
      ${hyprlandOnTty}/bin/hyprland-on-tty
    '';
  };
}
