{
  imports = [
    ./claude-code.nix
    ./gitnexus
    ./mattpocock-skills.nix
    ./team-skills.nix
  ];

  config.home.file = {
    ".claude/CLAUDE.md".source = ./CLAUDE.md;
    ".claude/commands/make-art.md".source = ./commands/make-art.md;
  };
}
