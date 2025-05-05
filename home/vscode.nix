{
  pkgs,
  lib,
  inputs,
  ...
}:
let
  vscode-marketplace = inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace;
in
{
  home.packages = [ pkgs.nil ];
  programs.vscode = {
    enable = true;
    profiles.default = {
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;

      userSettings = {
        "workbench.colorTheme" = lib.mkForce "Default Dark+";
        "workbench.iconTheme" = "vs-seti";
        "editor.fontFamily" = lib.mkForce "Menlo, Monaco, 'Courier New', monospace";

        "files.autoSave" = "onFocusChange";

        "[nix]" = {
          "editor.tabSize" = 2;
          "editor.formatOnSave" = true;
        };

        # Prettier configuration
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "prettier.singleQuote" = true;
        "prettier.trailingComma" = "all";
        "prettier.semi" = true;
        "prettier.tabWidth" = 2;
        "prettier.printWidth" = 100;

        "files.associations" = {
          "*.nix" = "nix";
        };

        # Format specific file types with Prettier
        "[javascript]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };

        "[go]" = {
          "editor.defaultFormatter" = "golang.go";
        };

        "[typescript]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[javascriptreact]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[typescriptreact]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[json]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[html]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[css]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "[markdown]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil"; # or "nixd"
        "nix.serverSettings" = {
          "nil" = {
            "formatting.command" = [ "nixfmt" ];
          };
          "nixd" = {
            "formatting.command" = [ "nixfmt" ];
          };
        };

      };

    };
  };
}
