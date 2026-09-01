#
# usb-audio.nix — USB interface hotplug routing (Home Manager)
#
# Watches ALSA card changes and switches PipeWire defaults to a non-dock USB
# interface, moving active playback streams (LibreWolf, spotify_player, etc.).
#
{
  config,
  lib,
  osConfig,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.usbAudio;
  audioEnabled = osConfig.${namespace}.audio.enable or false;
  switchScript = lib.${namespace}.switchUsbAudioScript pkgs;
in
{
  options.${namespace}.usbAudio.enable =
    lib.mkEnableOption "automatic USB audio interface selection on hotplug";

  config = lib.mkIf (cfg.enable && audioEnabled) {
    home.packages = [ switchScript ];

    systemd.user.paths.usb-audio-switch = {
      Unit = {
        Description = "Watch for USB audio hotplug";
        PartOf = [ "usb-audio-switch.service" ];
        After = [ "pipewire.service" "wireplumber.service" ];
      };
      Path = {
        PathChanged = "/proc/asound/cards";
      };
      Install.WantedBy = [ "pipewire.service" ];
    };

    systemd.user.services.usb-audio-switch = {
      Unit = {
        Description = "Switch default audio to USB interface";
        PartOf = [ "usb-audio-switch.path" ];
        After = [ "pipewire.service" "wireplumber.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe switchScript;
      };
    };

    # Run once at session start (path unit only fires on changes).
    systemd.user.services.usb-audio-switch-login = {
      Unit = {
        Description = "Initial USB audio routing at login";
        After = [ "pipewire.service" "wireplumber.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe switchScript;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}