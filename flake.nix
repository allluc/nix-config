{
  description = "My personal flake";
  inputs = {
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # The nixpkgs it-ops' system on the Framework is built from, for
    # packages that must match its Mesa driver. Keep in sync with
    # `nixos-version --json` (nixpkgsRevision) after each it-ops deploy.
    nixpkgs-system.url = "github:NixOS/nixpkgs/8ce4ef6cb6f871616146b9fe26d2a5ae594e94fe";
    # claude-code deliberately does NOT follow our nixpkgs: it is built
    # against its own pin so its cachix cache stays hit.
    claude-code.url = "github:sadjow/claude-code-nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    apple-fonts = {
      url = "github:Lyndeno/apple-fonts.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    font-patcher = {
      url = "github:ericwardner/font-patcher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    team-claude-skills = {
      url = "git+ssh://git@github.com/tiberius-grail/team-claude-skills";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };
    tiberius-nix = {
      url = "git+ssh://git@code.grail.tiberius.com/grail/TiberiusNix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      stylix,
      home-manager,
      disko,
      nixos-hardware,
      treefmt-nix,
      pre-commit-hooks,
      claude-code,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          claude-code.overlays.default
          inputs.tiberius-nix.overlays.default
        ];
      };
      user = {
        username = "alucas";
        fullName = "Alec Lucas";
        # Public half of the signingKey below; trusted in allowed_signers so
        # git can verify SSH-signed commits locally.
        sshPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEZL+B4pZYp2YYpUs7rOSw2kMHauFeOepwtO7ZANV2h+";
        work = {
          email = "alucas@tiberius.com";
          signingKey = "~/.ssh/id_ed25519.pub";
          githubOrg = "tiberius-grail";
        };
        personal = {
          email = "aleclfromnc@gmail.com";
          signingKey = "~/.ssh/id_ed25519.pub";
          githubUsername = "allluc";
        };
      };
      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
    in
    {
      formatter.${system} = treefmtEval.config.build.wrapper;
      checks.${system} = {
        pre-commit-check = pkgs.callPackage ./pre-commit.nix {
          inherit pre-commit-hooks treefmtEval;
        };
      };
      devShells.${system}.default = pkgs.mkShell {
        inherit (self.checks.${system}.pre-commit-check) shellHook;
        packages = [
          (self.checks.${system}.pre-commit-check.enabledPackages)
          treefmtEval.config.build.wrapper
        ];
        env = {
          CLAUDE_INSTANCE = "nix-config";
          CONTEXT_DOCS_ROOT = "/home/alucas/nix-config/.claude";
        };
      };
      nixosConfigurations =
        let
          hosts = {
            tiberius = {
              hardwareModules = [
                nixos-hardware.nixosModules.dell-precision-3490-intel
                nixos-hardware.nixosModules.common-gpu-intel
              ];
            };
            framework = {
              hardwareModules = [
                nixos-hardware.nixosModules.framework-amd-ai-300-series
              ];
            };
          };
          mkSystem =
            hostname:
            { hardwareModules }:
            nixpkgs.lib.nixosSystem {
              inherit pkgs system;
              specialArgs = {
                inherit user inputs;
              };
              modules = hardwareModules ++ [
                ./hosts/${hostname}/configuration.nix
                stylix.nixosModules.stylix
                disko.nixosModules.disko
              ];
            };
        in
        (builtins.mapAttrs mkSystem hosts)
        // {
          # Minimal Installation ISO (special case)
          iso = nixpkgs.lib.nixosSystem {
            inherit pkgs system;
            specialArgs = {
              inherit user;
            };
            modules = [ ./hosts/iso/configuration.nix ];
          };
        };
      homeConfigurations =
        let
          mkHome =
            hostname: extraModules:
            home-manager.lib.homeManagerConfiguration {
              inherit pkgs;
              extraSpecialArgs = {
                inherit inputs user;
              };
              modules = [
                {
                  home.username = user.username;
                  home.stateVersion = "25.05";
                  home.homeDirectory = "/home/${user.username}";
                }
                ./home/home.nix
                ./hosts/${hostname}/home-overrides.nix
                stylix.homeModules.stylix
              ]
              ++ extraModules;
            };
        in
        {
          "${user.username}@tiberius" = mkHome "tiberius" [ ];
          # The Framework laptop runs it-ops' NixOS config, whose hostname
          # is "alucas"; nh picks <user>@<hostname> by default. That system
          # has no Hyprland, so Home Manager installs it.
          "${user.username}@alucas" = mkHome "framework" [
            { modules.hyprland.standalone.enable = true; }
          ];
        };
    };
}
