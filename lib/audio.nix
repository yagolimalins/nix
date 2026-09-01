# PipeWire helpers for USB interface auto-routing.
{ lib, ... }:

let
  DOCK_DESC = "ThinkPad Dock USB Audio";
in
{
  # Switch default in/out to a non-dock USB interface and move active playback
  # streams; fall back to Intel HDMI when no interface is connected.
  switchUsbAudioScript =
    pkgs:
    pkgs.writeShellScriptBin "switch-usb-audio" ''
      set -euo pipefail

      DOCK_DESC=${lib.escapeShellArg DOCK_DESC}

      find_usb_node() {
        local class="$1"
        local prefix="$2"
        pw-dump 2>/dev/null | ${pkgs.jq}/bin/jq -r --arg class "$class" --arg prefix "$prefix" --arg dock "$DOCK_DESC" '
          .[]
          | select(.info.props["media.class"]? == $class)
          | select(.info.props["node.name"]? | startswith($prefix))
          | select(.info.props["node.description"]? != $dock)
          | .id' | head -1
      }

      move_playback_to_pw_node() {
        local pw_id="$1"
        local sink_name sink_idx input_idx

        sink_name=$(${pkgs.jq}/bin/jq -r --argjson id "$pw_id" '
          [.[] | select(.id == $id) | .info.props["node.name"]] | first // empty' \
          < <(pw-dump 2>/dev/null))
        [ -n "$sink_name" ] || return 0

        sink_idx=$(${pkgs.pulseaudio}/bin/pactl list short sinks \
          | ${pkgs.gawk}/bin/awk -v name="$sink_name" '$2 == name { print $1; exit }')
        [ -n "$sink_idx" ] || return 0

        while read -r input_idx _; do
          ${pkgs.pulseaudio}/bin/pactl move-sink-input "$input_idx" "$sink_idx" 2>/dev/null || true
        done < <(${pkgs.pulseaudio}/bin/pactl list short sink-inputs)
      }

      hdmi_fallback() {
        local card sink profile

        card=$(${pkgs.jq}/bin/jq -r '
          [.[] | select(.info.props["device.name"]? | test("^alsa_card\\.pci-")) | .id] | first // empty' \
          < <(pw-dump 2>/dev/null))
        [ -n "$card" ] || return 0

        for profile in 3 4 6 8 11 12; do
          ${pkgs.wireplumber}/bin/wpctl set-profile "$card" "$profile" 2>/dev/null || true
          sink=$(${pkgs.jq}/bin/jq -r '
            [.[] | select(.info.props["media.class"]? == "Audio/Sink")
             | select(.info.props["api.alsa.path"]? | test("hdmi")) | .id] | first // empty' \
            < <(pw-dump 2>/dev/null))
          [ -n "$sink" ] && break
        done

        [ -n "$sink" ] || return 0
        ${pkgs.wireplumber}/bin/wpctl set-default "$sink" 2>/dev/null || true
        move_playback_to_pw_node "$sink"
      }

      # Cards and profiles need a moment to settle after hotplug.
      sleep 1

      usb_out="$(find_usb_node "Audio/Sink" "alsa_output.usb-")"
      usb_in="$(find_usb_node "Audio/Source" "alsa_input.usb-")"

      if [ -n "$usb_out" ] || [ -n "$usb_in" ]; then
        if [ -n "$usb_out" ]; then
          ${pkgs.wireplumber}/bin/wpctl set-default "$usb_out" 2>/dev/null || true
          move_playback_to_pw_node "$usb_out"
        fi
        if [ -n "$usb_in" ]; then
          ${pkgs.wireplumber}/bin/wpctl set-default "$usb_in" 2>/dev/null || true
        fi
        exit 0
      fi

      hdmi_fallback
    '';
}