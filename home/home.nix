{ config, pkgs, ... }:
{
  imports = [
    ./tools/oath.nix
    ./tools/wf-recorder.nix
    ./tools/soundboard.nix
    ../modules/hm
  ];
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };
  stylix = {
    targets.k9s.enable = true;
    cursor.package = pkgs.rose-pine-cursor;
    cursor.name = "BreezeX-RosePine-Linux";
    cursor.size = 24;
  };
  # Stylix populates home.pointerCursor from stylix.cursor but doesn't set
  # enable; home-manager deprecated inferring it. Drop once stylix does
  # this itself.
  home.pointerCursor.enable = true;
  modules = {
    ai.gitnexus.enable = true;
    ai.mattpocock-skills.enable = true;
    ai.team-skills.enable = true;
    editors.vscode.enable = true;
    editors.neovim.enable = true;
    editors.zed.enable = true;
  };
  home.packages = with pkgs; [
    networkmanagerapplet
    mpv
    stremio-linux-shell
    gimp3
    inkscape
    brave
    discord
    unzip
    pavucontrol
    openssl
    libnotify
    yubioath-flutter
    stern
    ssm-session-manager-plugin
    pcsc-tools
    v4l-utils
    cameractrls
    (wrapOBS {
      plugins = with obs-studio-plugins; [
        wlrobs
        obs-pipewire-audio-capture
        obs-backgroundremoval
      ];
    })
    (pkgs.writeShellScriptBin "setup-browser-CAC" ''
      NSSDB="''${HOME}/.pki/nssdb"
      mkdir -p ''${NSSDB}

      ${pkgs.nssTools}/bin/modutil -force -dbdir sql:$NSSDB -add yubi-smartcard \
        -libfile ${pkgs.opensc}/lib/opensc-pkcs11.so
    '')
    (pkgs.writeShellScriptBin "launch-webapp" ''
      exec ${config.programs.google-chrome.finalPackage}/bin/google-chrome-stable --app="$1" "''${@:2}"
    '')
    (pkgs.writeShellScriptBin "system-menu" ''
      choice=$(printf "󰌾  Lock\n󰤄  Sleep\n  Reboot\n󰐥  Shutdown\n󰗽  Logout" | ${pkgs.fuzzel}/bin/fuzzel --dmenu -p "System: ")
      case "$choice" in
        *Lock*) loginctl lock-session ;;
        *Sleep*) systemctl suspend-then-hibernate ;;
        *Reboot*) systemctl reboot ;;
        *Shutdown*) systemctl poweroff ;;
        *Logout*) hyprctl dispatch 'hl.dsp.exit()' ;;
      esac
    '')
  ];

  programs = {
    kitty.settings = {
      scrollback_lines = 100000;
      copy_on_select = "clipboard";
    };
    google-chrome = {
      enable = true;
      package = pkgs.google-chrome;
    };
  };
  # Linear ships no Linux desktop app; run the web app in a Chrome app window.
  xdg.desktopEntries.linear = {
    name = "Linear";
    exec = "launch-webapp https://linear.app";
    icon = "applications-office";
    categories = [
      "Office"
      "ProjectManagement"
    ];
  };
  home.sessionVariables = {
    BROWSER = "google-chrome-stable";
    EDITOR = "vim";
    SOPS_AGE_SSH_PRIVATE_KEY_FILE = "$HOME/.ssh/id_ed25519_sops";
    KUBECONFIG = "$HOME/.kube/config";
  };
  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
  };

  stylix.targets.gtk.extraCss = ''
    /* Menu hover styling for GTK apps */
    window > menu > menuitem:hover,
    window > menu > menuitem:hover > check,
    window > menu > menuitem:hover > box,
    window > menu > menuitem:hover > box > *,
    window > menu > menuitem:hover > label,
    window > menu > menuitem:hover > label > *,
    window > menu > menuitem:hover > arrow {
      background-color: @theme_selected_bg_color;
      color: @theme_selected_fg_color;
    }
  '';
}
