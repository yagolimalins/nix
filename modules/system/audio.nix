{ config, pkgs, ... }:

{
  ############################################################
  # Realtime privileges (audio & RT threads)
  ############################################################

  security.rtkit.enable = true;

  security.pam.loginLimits = [
    { domain = "@audio";    type = "-"; item = "rtprio";  value = "95";        }
    { domain = "@audio";    type = "-"; item = "memlock"; value = "unlimited"; }
    { domain = "@realtime"; type = "-"; item = "rtprio";  value = "95";        }
    { domain = "@realtime"; type = "-"; item = "memlock"; value = "unlimited"; }
  ];

  ############################################################
  # PipeWire (replaces PulseAudio)
  ############################################################

  services.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    wireplumber.enable = true;

    alsa = {
      enable = true;
      support32Bit = true;
    };

    pulse.enable = true;
    jack.enable  = true;

    # Auto-connect Bluetooth headsets in A2DP (high-quality) mode
    wireplumber.extraConfig."10-bluetooth-autoswitch" = {
      "monitor.bluez.rules" = [
        {
          matches = [{ "device.name" = "~bluez_card.*"; }];
          actions.update-props = {
            "bluez5.auto-connect" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
          };
        }
      ];
    };

    extraConfig.pipewire."10-audio-settings" = {
      context.properties = {
        default.clock.rate          = 48000;
        default.clock.allowed-rates = [ 44100 48000 96000 ];
        default.clock.quantum       = 128;
        default.clock.min-quantum   = 128;
        default.clock.max-quantum   = 128;
        default.clock.quantum-limit = 1024;
      };
    };
  };
}
