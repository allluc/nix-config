{ ... }: {
  programs.zsh = {
    sessionVariables.EDITOR = "vim";
    initExtra = ''
      # Run neofetch on terminal launch
      neofetch --ascii ~/.config/neofetch/ascii.txt
    '';
    shellAliases = {
      pp = "pulumi";
      creds = "source ~/.config/2fctl/credentials.sh";
      signal =
        "signal-desktop --ozone-platform-hint=wayland & sleep 1 && signal-desktop";
      shell = "nix develop -c $SHELL";
      neofetch = "neofetch --ascii ~/.config/neofetch/ascii.txt";
      gct = "git commit --template ~/.gitmessage";
      gcat = "git commit --all --template ~/.gitmessage";
      gsign = "git commit --amend --no-edit --signoff";
      cal = "gcalcli agenda";
      edithome = "cd ~/nix-config && zed .";
      format = "nixfmt ~/nix-config";
      auth = "ykman oath accounts code --single 'DevSecOps Collaboration Workspace:alec.lucas' | wl-copy";
    };
  };
}
