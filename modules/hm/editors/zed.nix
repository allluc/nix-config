{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.editors;
  inherit (lib) mkIf mkEnableOption;
in
{
  options.modules.editors.zed.enable = mkEnableOption "Enable Zed" // {
    default = false;
  };

  config = mkIf cfg.zed.enable {
    # nixpkgs installs Zed's CLI as `zeditor`
    home.shellAliases.zed = "zeditor";

    programs.zed-editor = {
      enable = true;
      # Zed can't fetch working nix language servers on its own; put them
      # on its PATH. Other languages' servers are downloaded by Zed.
      extraPackages = with pkgs; [
        nixd
        nil
        nixfmt
      ];
      extensions = [
        "nix"
        "toml"
      ];
    };
  };
}
