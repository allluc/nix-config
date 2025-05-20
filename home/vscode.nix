{ pkgs, lib, inputs, ... }:
let
  vscode-marketplace =
    inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
in { home.packages = [ pkgs.nil pkgs.vscode ]; }
