{ config, lib, ... }:
let
  cfg = config.modules.terminals;
  inherit (lib) mkIf mkEnableOption;
in
{
  options = {
    modules.terminals.kitty.enable = mkEnableOption "Enable Kitty terminal" // {
      default = true;
    };
  };
  config = mkIf cfg.kitty.enable {
    programs.kitty = {
      enable = true;
      # The login shell can be bash (e.g. on it-ops' system config), so
      # start zsh directly.
      settings.shell = mkIf config.programs.zsh.enable "${config.programs.zsh.package}/bin/zsh";
      extraConfig = ''
        allow_remote_control yes
      '';
    };

    # Default terminal for apps/launchers that need one: .desktop entries
    # with Terminal=true and GNOME go through xdg-terminal-exec; fuzzel and
    # most CLI tools read $TERMINAL.
    xdg.terminal-exec = {
      enable = true;
      settings.default = [ "kitty.desktop" ];
    };
    home.sessionVariables.TERMINAL = "kitty";
  };
}
