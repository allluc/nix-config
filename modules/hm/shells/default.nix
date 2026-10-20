{ config, ... }:
{
  imports = [
    ./zsh.nix
    ./bash.nix
  ];

  # Shared by every enabled shell, so the aliases also work where the
  # login shell is still bash (e.g. a machine whose NixOS config isn't
  # managed by this flake).
  home.shellAliases =
    let
      flakeDir = "$HOME/nix-config";
    in
    {
      rb = "nh os switch ${flakeDir}";
      rbh = "nh home switch ${flakeDir}";
      upd = "nh home switch ${flakeDir} --update";
      gct = "git commit";
      open = "xdg-open";
      nosleep = ''systemd-inhibit --what=sleep:idle:handle-lid-switch:handle-power-key --who="$USER" --why="no sleep" --mode=block sleep infinity'';
    };

  # Installs nh per-user; the NixOS programs.nh only exists on hosts
  # built from this flake.
  programs.nh = {
    enable = true;
    flake = "${config.home.homeDirectory}/nix-config";
  };
}
