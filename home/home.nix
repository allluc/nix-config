{ config, pkgs, inputs, lib, ... }: {
  imports = [ ./zsh.nix ./vscode.nix ];

  nixpkgs = {
    overlays = [ inputs.nur.overlay ];
    config = { allowUnfree = true; };
  };

  stylix = {
    enable = true;
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
    base16Scheme =
      lib.mkForce "${pkgs.base16-schemes}/share/themes/gruvbox-dark-soft.yaml";

    opacity = lib.mkForce {
      applications = 1.0;
      terminal = 0.8;
      desktop = 1.0;
      popups = 1.0;
    };
  };

  secondfront.hyprland = {
    monitors = [
      {
        name = "eDP-1";
        position = "auto";
        width = 1920;
        height = 1200;
        enabled = false;
        refreshRate = 60;
      }
      {
        name = "DP-5";
        position = "auto-right";
        width = 3840;
        height = 2160;
        refreshRate = 60;
      }
      {
        name = "DP-6";
        position = "auto-left";
        width = 3840;
        height = 2160;
        refreshRate = 60;
      }
    ];
  };

  home.packages = with pkgs; [
    google-chrome
    signal-desktop
    twofctl
    pulumi-bin
    nixfmt
    base16-schemes
    pulseaudio
    openssl
    neofetch
    sops
    gimp
    go
    gotools
    go-mockery
    pre-commit
    bash
    inputs.pyprland.packages.${pkgs.system}.default
    networkmanager
    xarchiver
    cargo
    rustfmt
    typescript
    libnotify
    claude-code
    gcc
    rust-analyzer
    gcalcli
    gopls
    # swaynotificationcenter
    libcanberra
    spotify
    obs-studio
    hyprsunset
    postgresql
    mysql80
    pgloader
    nodejs_24
    rustc
    wine
    winetricks
    lutris
    vulkan-tools
    dxvk
    cdrtools
  ];

  services.hyprpaper = {
    enable = true;
    settings.preload = [ "${config.home.homeDirectory}/Wallpapers/2fx.png" ];
    settings.wallpaper = [
      "DP-7,${config.home.homeDirectory}/Wallpapers/2fx.png"
      "DP-8,${config.home.homeDirectory}/Wallpapers/2fx.png"
    ];
  };

  # services.mako = lib.mkForce { enable = false; };
  # services.swaync = {
  #   enable = true;
  #   package = pkgs.swaynotificationcenter;
  #   settings = builtins.fromJSON (builtins.readFile ./swaync/config.json);
  #   style = builtins.readFile ./swaync/styles.css;
  # };

  programs.hyprlock.settings = {
    background = [{ color = "rgba(0, 0, 0, 1.0)"; }];
  };

  programs.firefox = {
    enable = true;
    policies = {
      SecurityDevices = {
        Add = { "Yubikey/Smartcard" = "${pkgs.opensc}/lib/opensc-pkcs11.so"; };
      };
      ExtensionSettings = with builtins;
        let
          extension = shortId: uuid: {
            name = uuid;
            value = {
              install_url =
                "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
              installation_mode = "force_installed";
            };
          };
        in listToAttrs [
          (extension "ublock-origin" "uBlock0@raymondhill.net")
          (extension "bitwarden-password-manager"
            "{446900e4-71c2-419f-a6a7-df9c091e268b}")
          (extension "vimium-ff" "{d7742d87-e61d-4b78-b8a1-b469842139fa}")
        ];
    };
    profiles.aleclucas = {
      search = {
        force = true;
        default = "google";
        order = [ "google" ];
        engines = {
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                {
                  name = "type";
                  value = "packages";
                }
                {
                  name = "query";
                  value = "{searchTerms}";
                }
              ];
            }];
            icon =
              "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
          "NixOS Wiki" = {
            urls = [{
              template = "https://nixos.wiki/index.php?search={searchTerms}";
            }];
            icon = "https://nixos.wiki/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@nw" ];
          };
          "bing".metaData.hidden = true;
          "google".metaData.alias =
            "@g"; # builtin engines only support specifying one additional alias
        };
      };
    };
  };

  programs.zed-editor = {
    enable = true;
    userSettings = {
      lsp = {
        go = {
          command = "gopls";
          initialization_options = {
            usePlaceholders = true;
            completeUnimported = true;
          };
        };
      };
    };
  };

  programs.k9s = {
    settings = { k9s = { refreshRate = 3; }; };
    plugin = {
      plugins = {
        network-test = {
          shortCut = "Ctrl-T";
          description = "Pick network test";
          scopes = [ "pods" ];
          command = "sh";
          background = false;
          args = [
            "-c"
            ''
              kubectl run -it -n $NAMESPACE network-test \
                --image=registry1.dso.mil/ironbank/opensource/kubernetes-e2e-test/dnsutils:1.3-ubi9 \
                --overrides='{
                  "apiVersion": "v1",
                  "spec": {
                    "containers": [{
                      "name": "network-test",
                      "image": "registry1.dso.mil/ironbank/opensource/kubernetes-e2e-test/dnsutils:1.3-ubi9",
                      "command": ["/bin/bash"],
                      "args": ["-c", "sleep 10000"],
                      "serviceAccount": "karpenter",
                      "securityContext": {
                        "capabilities": {
                          "drop": ["ALL"]
                        }
                      }
                    }],
                    "imagePullSecrets": [{
                      "name": "private-registry"
                    }]
                  }
                }' \
                --command -- bash
            ''
          ];
        };
      };
    };

    views = {
      views = {
        "ks" = {
          columns =
            [ "NAMESPACE" "NAME" "SUS:.spec.suspend" "READY" "STATUS" "AGE" ];
        };
        "hr" = {
          columns =
            [ "NAMESPACE" "NAME" "SUS:.spec.suspend" "READY" "STATUS" "AGE" ];
        };
      };
    };
  };

  wayland.windowManager.hyprland = {
    settings = {
      exec-once = [
        "systemctl --user import-environment PATH && systemctl --user restart xdg-desktop-portal.service"
        "swaync"
      ];

      general = lib.mkForce { };
      decoration = lib.mkOverride 1000 {
        rounding = 10;

        blur = {
          enabled = true;
          size = 8;
          passes = 2;
        };

        shadow = {
          enabled = true;
          range = 15;
          render_power = 3;
          offset = "0, 0";
        };
      };

      windowrule = [
        "float,class:^(dropdown)$"
        "size 800 400,class:^(dropdown)$"
        "center,class:^(dropdown)$"
        "animation slide,class:^(dropdown)$"
        "float, title:^(MainPicker)$"
        "float, title:^(Sign in to Security Device)$"
        "workspace 10,title:^(app.gather.town is sharing)(.*)$"
      ];

      bind = [
        "$mainMod, A, exec, swaync-client -t -sw"
        "$mainMod, V, exec, cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"
        "$mainMod, G, togglegroup"
        "$mainMod, Return, exec, nvidia-offload kitty"
        "$mainMod, Y, exec, ykmanoath"
        "$mainMod, Q, killactive,"
        "$mainMod, D, exec, pypr expose"
        "$mainMod, E, exec, thunar"
        "$mainMod, F, togglefloating,"
        "$mainMod, SPACE, exec, fuzzel"
        "$mainMod, P, pseudo, # dwindle"
        "$mainMod, S, togglesplit, # dwindle"
        "$mainMod, TAB, workspace, previous"
        ",F11,fullscreen"
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, changegroupactive, f"
        "$mainMod, j, changegroupactive, b"
        "$mainMod ALT, J, changegroupactive, f"
        "$mainMod ALT, K, changegroupactive, b"
        "$mainMod SHIFT, h, movewindoworgroup, l"
        "$mainMod SHIFT, l, movewindoworgroup, r"
        "$mainMod SHIFT, k, movewindoworgroup, u"
        "$mainMod SHIFT, j, movewindoworgroup, d"
        "$mainMod CTRL, h, resizeactive, -60 0"
        "$mainMod CTRL, l, resizeactive,  60 0"
        "$mainMod CTRL, k, resizeactive,  0 -60"
        "$mainMod CTRL, j, resizeactive,  0  60"
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        "$mainMod SHIFT, 1, movetoworkspacesilent, 1"
        "$mainMod SHIFT, 2, movetoworkspacesilent, 2"
        "$mainMod SHIFT, 3, movetoworkspacesilent, 3"
        "$mainMod SHIFT, 4, movetoworkspacesilent, 4"
        "$mainMod SHIFT, 5, movetoworkspacesilent, 5"
        "$mainMod SHIFT, 6, movetoworkspacesilent, 6"
        "$mainMod SHIFT, 7, movetoworkspacesilent, 7"
        "$mainMod SHIFT, 8, movetoworkspacesilent, 8"
        "$mainMod SHIFT, 9, movetoworkspacesilent, 9"
        "$mainMod SHIFT, 0, movetoworkspacesilent, 10"
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
        "$mainMod, F3, exec, brightnessctl -d *::kbd_backlight set +33%"
        "$mainMod, F2, exec, brightnessctl -d *::kbd_backlight set 33%-"
        ", XF86AudioRaiseVolume, exec, pamixer -i 5 "
        ", XF86AudioLowerVolume, exec, pamixer -d 5 "
        ", XF86AudioMute, exec, pamixer -t"
        ", XF86AudioMicMute, exec, pamixer --default-source -m"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%- "
        ", XF86MonBrightnessUp, exec, brightnessctl set +5% "
        '', Print, exec, grim -g "$(slurp)" - | swappy -f -''
        "$mainMod, B, exec, pkill -SIGUSR1 waybar"
        "$mainMod, W, exec, pkill -SIGUSR2 waybar"
      ];
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}
