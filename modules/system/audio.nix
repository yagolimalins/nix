#
# audio.nix — PipeWire audio + realtime privileges
#
# Low-latency PipeWire (ALSA/Pulse/JACK) tuned for 44.1 kHz hardware,
# Bluetooth codec preferences, USB-audio prioritisation, and the RT
# scheduling limits pro-audio (@audio/@realtime groups) needs.
#
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

    wireplumber.extraConfig."10-bluez" = {
      "monitor.bluez.properties" = {
        "bluez5.msbc-support"   = true;
        "bluez5.sbc-xq-support" = true;
        "bluez5.codecs"         = [ "sbc_xq" "sbc" "aac" "msbc" ];
      };
    };

    wireplumber.extraConfig."12-disable-builtin-mic" = {
      "monitor.alsa.rules" = [
        {
          matches = [{ "node.name" = "~alsa_input.pci-.*"; }];
          actions.update-props = {
            "node.disabled" = true;
          };
        }
      ];
    };

    wireplumber.extraConfig."11-usb-audio-priority" = {
      "monitor.alsa.rules" = [
        {
          matches = [{ "device.name" = "~alsa_card.usb-.*"; }];
          actions.update-props = {
            "device.profile" = "pro-audio";
          };
        }
        {
          matches = [
            { "node.name" = "~alsa_output.usb-.*"; }
            { "node.name" = "~alsa_input.usb-.*"; }
          ];
          actions.update-props = {
            "priority.session" = 2000;
          };
        }
      ];
    };

    # Global Audio Engine Settings (Optimized for 44.1kHz Hardware)
    extraConfig.pipewire."10-audio-settings" = {
      "context.properties" = {
        "default.clock.rate"          = 44100; 
        "default.clock.allowed-rates" = [ 44100 48000 96000 ];
        "default.clock.quantum"       = 128;   
        "default.clock.min-quantum"   = 32;    
        "default.clock.max-quantum"   = 2048;  
        "default.clock.quantum-limit" = 8192;
      };
      "context.modules" = [
        {
          name = "libpipewire-module-rt";
          args = {
            "nice.level"   = -11;
            "rt.prio"      = 88;
          };
          flags = [ "ifexists" "nofail" ];
        }
      ];
      "settings" = {
        "settings.check-quantum" = true; 
      };
    };

    # FIXED: Replaced extraConfig.pipewire-jack with extraConfig.jack
    extraConfig.jack."10-jack-settings" = {
      "jack.properties" = {
        "node.latency"       = "128/44100";
        "node.force-quantum" = 128;
      };
    };
  };
}