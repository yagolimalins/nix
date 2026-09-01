#
# audio.nix — PipeWire audio + realtime privileges
#
# Low-latency PipeWire (ALSA/Pulse/JACK) tuned for 44.1 kHz hardware,
# Bluetooth codec preferences, USB-audio prioritisation, and the RT
# scheduling limits pro-audio (@audio/@realtime groups) needs.
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.audio;
in
{
  options.${namespace}.audio.enable =
    lib.mkEnableOption "PipeWire audio stack with realtime privileges";

  config = lib.mkIf cfg.enable {
    ############################################################
    # Realtime privileges (audio & RT threads)
    ############################################################

    security.rtkit.enable = true;

    security.pam.loginLimits = [
      {
        domain = "@audio";
        type = "-";
        item = "rtprio";
        value = "95";
      }
      {
        domain = "@audio";
        type = "-";
        item = "memlock";
        value = "unlimited";
      }
      {
        domain = "@realtime";
        type = "-";
        item = "rtprio";
        value = "95";
      }
      {
        domain = "@realtime";
        type = "-";
        item = "memlock";
        value = "unlimited";
      }
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
      jack.enable = true;

      # Auto-connect Bluetooth headsets in A2DP (high-quality) mode
      wireplumber.extraConfig."10-bluetooth-autoswitch" = {
        "monitor.bluez.rules" = [
          {
            matches = [ { "device.name" = "~bluez_card.*"; } ];
            actions.update-props = {
              "bluez5.auto-connect" = [
                "hfp_hf"
                "hsp_hs"
                "a2dp_sink"
              ];
            };
          }
        ];
      };

      wireplumber.extraConfig."10-bluez" = {
        "monitor.bluez.properties" = {
          "bluez5.msbc-support" = true;
          "bluez5.sbc-xq-support" = true;
          "bluez5.codecs" = [
            "sbc_xq"
            "sbc"
            "aac"
            "msbc"
          ];
        };
      };

      wireplumber.extraConfig."12-disable-builtin-mic" = {
        "monitor.alsa.rules" = [
          {
            matches = [ { "node.name" = "~alsa_input.pci-.*"; } ];
            actions.update-props = {
              "node.disabled" = true;
            };
          }
        ];
      };

      wireplumber.extraConfig."12-usb-interface-priority" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "device.bus" = "usb"; }
              { "device.name" = "~alsa_card.usb-.*"; }
            ];
            actions.update-props = {
              "priority.session" = 2300;
              "priority.driver" = 2300;
            };
          }
          {
            matches = [ { "node.name" = "~alsa_output.usb-.*"; } ];
            actions.update-props = {
              "priority.session" = 2300;
              "priority.driver" = 2300;
            };
          }
          {
            matches = [ { "node.name" = "~alsa_input.usb-.*"; } ];
            actions.update-props = {
              "priority.session" = 2300;
              "priority.driver" = 2300;
            };
          }
        ];
      };

      # M-Vave BlackBox (Jieli 4c4a:c755) — ALSA reports "USB Composite Device".
      wireplumber.extraConfig."12-mvave-blackbox" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "device.vendor.id" = "0x4c4a"; }
              { "device.product.id" = "0xc755"; }
            ];
            actions.update-props = {
              "device.description" = "M-Vave BlackBox";
              "device.nick" = "M-Vave BlackBox";
            };
          }
          {
            matches = [
              { "device.vendor.id" = "0x4c4a"; }
              { "device.product.id" = "0xc755"; }
              { "node.name" = "~alsa_output.usb-.*"; }
            ];
            actions.update-props = {
              "node.description" = "M-Vave BlackBox";
              "node.nick" = "M-Vave BlackBox";
            };
          }
          {
            matches = [
              { "device.vendor.id" = "0x4c4a"; }
              { "device.product.id" = "0xc755"; }
              { "node.name" = "~alsa_input.usb-.*"; }
            ];
            actions.update-props = {
              "node.description" = "M-Vave BlackBox";
              "node.nick" = "M-Vave BlackBox";
            };
          }
        ];
      };

      # After 12-usb-interface-priority — dock must stay below HDMI/interfaces.
      wireplumber.extraConfig."14-thinkpad-dock-audio" = {
        "monitor.alsa.rules" = [
          {
            # 40AJ dock USB audio is the analog jack; monitor speakers use Intel HDMI.
            matches = [
              { "device.vendor.id" = "0x17ef"; }
              { "device.product.id" = "0x306f"; }
            ];
            actions.update-props = {
              "device.profile" = "output:analog-stereo+input:analog-stereo";
              "priority.driver" = 100;
              "priority.session" = 100;
            };
          }
          {
            matches = [ { "node.description" = "ThinkPad Dock USB Audio"; } ];
            actions.update-props = {
              "priority.session" = 100;
              "priority.driver" = 100;
            };
          }
        ];
      };

      wireplumber.extraConfig."11-pci-acp-auto-profile" = {
        "monitor.alsa.rules" = [
          {
            matches = [ { "device.name" = "~alsa_card.pci-.*"; } ];
            actions.update-props = {
              "api.acp.auto-profile" = true;
              "api.acp.auto-port" = true;
            };
          }
        ];
      };

      wireplumber.extraConfig."15-stream-follow-default" = {
        wireplumber.settings = {
          linking.follow-default-target = true;
          linking.allow-moving-streams = true;
        };
      };

      wireplumber.extraConfig."13-hdmi-output-priority" = {
        "monitor.alsa.rules" = [
          {
            matches = [ { "node.name" = "~alsa_output.pci.*hdmi.*"; } ];
            actions.update-props = {
              "priority.session" = 2100;
              "priority.driver" = 2100;
            };
          }
        ];
      };

      # Global Audio Engine Settings (Optimized for 44.1kHz Hardware)
      extraConfig.pipewire."10-audio-settings" = {
        "context.properties" = {
          "default.clock.rate" = 44100;
          "default.clock.allowed-rates" = [
            44100
            48000
            96000
          ];
          "default.clock.quantum" = 128;
          "default.clock.min-quantum" = 32;
          "default.clock.max-quantum" = 2048;
          "default.clock.quantum-limit" = 8192;
        };
        "context.modules" = [
          {
            name = "libpipewire-module-rt";
            args = {
              "nice.level" = -11;
              "rt.prio" = 88;
            };
            flags = [
              "ifexists"
              "nofail"
            ];
          }
        ];
        "settings" = {
          "settings.check-quantum" = true;
        };
      };

      # FIXED: Replaced extraConfig.pipewire-jack with extraConfig.jack
      extraConfig.jack."10-jack-settings" = {
        "jack.properties" = {
          "node.latency" = "128/44100";
          "node.force-quantum" = 128;
        };
      };
    };
  };
}
