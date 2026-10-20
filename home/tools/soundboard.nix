{ lib, pkgs, ... }:
let
  soundboard = pkgs.writeShellApplication {
    name = "soundboard";

    runtimeInputs = with pkgs; [
      fuzzel
      mpv
      libnotify
      xdg-utils
      util-linux
      findutils
    ];

    text = builtins.readFile ./soundboard;
  };

  # Clips play into "Soundboard"; your default mic and the clips are mixed in
  # "soundboard_mix", which is exposed as the "Soundboard Mic" source. Clips
  # are also looped back to the default output so you hear them.
  loopback = description: capture: playback: {
    name = "libpipewire-module-loopback";
    args = {
      "node.description" = description;
      "capture.props" = capture;
      "playback.props" = playback;
    };
  };
  # A missing target must never fall back to the default device, or the mic
  # would be piped into your headphones.
  pinnedTo = target: {
    "target.object" = target;
    "node.dont-reconnect" = true;
    "node.dont-fallback" = true;
  };
  monitorOf =
    sink:
    pinnedTo sink
    // {
      "stream.capture.sink" = true;
      "node.passive" = true;
    };
  nullSink = name: description: {
    factory = "adapter";
    args = {
      "factory.name" = "support.null-audio-sink";
      "node.name" = name;
      "node.description" = description;
      "media.class" = "Audio/Sink";
      "audio.position" = [
        "FL"
        "FR"
      ];
      "priority.session" = 1;
    };
  };
in
{
  home.packages = [ soundboard ];

  xdg.configFile."pipewire/pipewire.conf.d/50-soundboard.conf".text = builtins.toJSON {
    "context.objects" = [
      (nullSink "soundboard" "Soundboard")
      (nullSink "soundboard_mix" "Soundboard Mix")
    ];
    "context.modules" = [
      (loopback "Soundboard clips to mix" (
        monitorOf "soundboard" // { "node.name" = "soundboard_clips_tap"; }
      ) (pinnedTo "soundboard_mix" // { "node.name" = "soundboard_clips_to_mix"; }))
      (loopback "Soundboard clips to speakers" (
        monitorOf "soundboard" // { "node.name" = "soundboard_clips_listen"; }
      ) { "node.name" = "soundboard_clips_to_speakers"; })
      (loopback "Soundboard voice to mix" { "node.name" = "soundboard_voice"; } (
        pinnedTo "soundboard_mix" // { "node.name" = "soundboard_voice_to_mix"; }
      ))
      (loopback "Soundboard Mic" (monitorOf "soundboard_mix" // { "node.name" = "soundboard_mix_tap"; }) {
        "node.name" = "soundboard_mic";
        "node.description" = "Soundboard Mic";
        "media.class" = "Audio/Source";
        "audio.position" = [
          "FL"
          "FR"
        ];
        "priority.session" = 1;
      })
    ];
  };

  home.activation.soundboardDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/Documents/sounds"
  '';
}
