{
  modules = {
    hyprpaper.wallpaper = toString ../../modules/stylix/assets/walls/AI_UKRAINE.png;
    hyprland.monitors = [
      {
        name = "eDP-1";
        workspace = "10";
        enabled = true;
        scale = "1.6";
      }
      {
        name = "desc:GIGA-BYTE TECHNOLOGY CO. LTD. Gigabyte M32U 22181B002365";
        workspace = "1";
        resolution = "3840x2160@144";
        position = "-3072x-1000";
        scale = "1.25";
      }
      {
        name = "desc:ESP eD13(2022) 0x00023552";
        resolution = "highres";
        position = "auto-left";
        scale = "1";
      }
      {
        name = "desc:Sceptre Tech Inc Sceptre Z27";
        resolution = "3840x2160@60";
        position = "auto-right";
        scale = "1.5";
      }
    ];
  };
  # Keeps Chrome off the NVIDIA dGPU (c1:00.0).
  programs.google-chrome.commandLineArgs = [
    "--render-node-override=/dev/dri/by-path/pci-0000:c2:00.0-render"
  ];
}
