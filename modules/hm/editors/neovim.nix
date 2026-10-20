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
  options.modules.editors.neovim.enable = mkEnableOption "Enable Neovim with LazyVim" // {
    default = false;
  };

  config = mkIf cfg.neovim.enable {
    # LazyVim manages its own colorscheme; stylix's base16 plugin would
    # fight it (and lazy.nvim resets the packpath stylix installs into).
    stylix.targets.neovim.enable = false;

    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      withPython3 = true;

      # Mason's prebuilt binaries are dynamically linked for generic
      # distros and mostly fail on NixOS, so LazyVim runs with Mason
      # disabled and language servers/formatters come from here instead.
      extraPackages = with pkgs; [
        # LazyVim runtime deps: plugin fetching, treesitter parser builds,
        # pickers, clipboard
        git
        curl
        unzip
        gcc
        gnumake
        tree-sitter
        ripgrep
        fd
        lazygit
        wl-clipboard
        # lua (LazyVim default)
        lua-language-server
        stylua
        # nix (lang.nix extra)
        nil
        nixfmt
        # shell
        bash-language-server
        shellcheck
        shfmt
      ];

      # LazyVim starter bootstrap. lazy.nvim clones itself and the plugins
      # into ~/.local/share/nvim on first launch, so plugin versions are
      # pinned by lazy-lock.json (written next to init.lua), not by Nix.
      initLua = ''
        local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
        if not vim.uv.fs_stat(lazypath) then
          vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "--branch=stable",
            "https://github.com/folke/lazy.nvim.git",
            lazypath,
          })
        end
        vim.opt.rtp:prepend(lazypath)

        require("lazy").setup({
          spec = {
            { "LazyVim/LazyVim", import = "lazyvim.plugins" },
            { import = "lazyvim.plugins.extras.lang.nix" },
            { import = "plugins" },
          },
          defaults = { lazy = false, version = false },
          install = { colorscheme = { "tokyonight", "habamax" } },
          checker = { enabled = true, notify = false },
        })
      '';
    };

    xdg.configFile."nvim/lua/plugins/nix.lua".text = ''
      -- Tools are provided by Nix (see modules/hm/editors/neovim.nix).
      return {
        { "mason-org/mason.nvim", enabled = false },
        { "mason-org/mason-lspconfig.nvim", enabled = false },
        {
          "neovim/nvim-lspconfig",
          opts = {
            servers = {
              bashls = {},
            },
          },
        },
      }
    '';
  };
}
