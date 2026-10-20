{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.shells;
  inherit (lib) mkIf mkEnableOption;
in
{
  options = {
    modules.shells.bash.enable = mkEnableOption "Enable bash" // {
      default = true;
    };
  };
  config = mkIf cfg.bash.enable {
    programs.bash = {
      enable = true;
      enableCompletion = true;
    };
  };
}
