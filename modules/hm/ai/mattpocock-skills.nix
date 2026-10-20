{
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.ai.mattpocock-skills;
  src = inputs.mattpocock-skills;
  skillDirs = (lib.importJSON "${src}/.claude-plugin/plugin.json").skills;
  skillNames = map baseNameOf skillDirs;
in
{
  options.modules.ai.mattpocock-skills = {
    enable = lib.mkEnableOption "Matt Pocock's agent skills (github:mattpocock/skills)";
  };

  config = lib.mkIf cfg.enable {
    home.activation.mattpocock-skills = lib.hm.dag.entryAfter [ "claude-skills" ] ''
      mkdir -p $HOME/.claude/skills
      for skill in ${lib.concatStringsSep " " skillNames}; do
        rm -rf $HOME/.claude/skills/$skill
      done
      ${lib.concatMapStringsSep "\n" (dir: "cp -rL ${src}/${dir} $HOME/.claude/skills/") skillDirs}
      chmod -R u+rw $HOME/.claude/skills
    '';
  };
}
