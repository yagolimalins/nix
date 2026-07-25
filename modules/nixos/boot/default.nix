#
# boot.nix — Bootloader, kernel and low-level tuning
#
# Lanzaboote (Secure Boot) replaces systemd-boot, plus kernel package/params,
# tmpfs /tmp, kernel sysctls and redistributable firmware (CPU microcode).
#
# Secure Boot enrollment (once per machine):
#
#   ./install.sh already runs `sbctl create-keys` before the first rebuild.
#   Manual / existing hosts:
#
#   1. sudo sbctl create-keys          # if /var/lib/sbctl does not exist yet
#   2. nh os switch / nixos-rebuild    # so generations are signed
#   3. sudo sbctl verify
#   4. Firmware: enable Setup Mode (clear existing Secure Boot keys)
#   5. sudo sbctl enroll-keys -m       # -m keeps Microsoft keys (BitLocker/etc.)
#   6. Firmware: enable Secure Boot, disable Setup Mode, reboot
#   7. bootctl status / sbctl status   # confirm Secure Boot is active
#
# Temporarily bail out with:  mine.boot.secureBoot = false;
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.boot;
in
{
  options.${namespace}.boot = {
    enable = lib.mkEnableOption "bootloader, kernel and low-level system tuning";

    secureBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Use Lanzaboote for UEFI Secure Boot (signed UKIs). When false, falls
        back to unsigned systemd-boot.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        boot = {
          loader.efi.canTouchEfiVariables = true;
          loader.systemd-boot.configurationLimit = 5;

          # Lanzaboote owns the EFI bootloader when Secure Boot is on.
          loader.systemd-boot.enable = lib.mkForce (!cfg.secureBoot);

          kernelPackages = pkgs.linuxPackages_latest;
          kernelParams = [
            "quiet"
            "loglevel=3"
          ];

          initrd.systemd.enable = true;

          tmp.useTmpfs = true; # /tmp in RAM: faster builds, auto-cleared on reboot
        };

        # Prefer zram over disk swap aggressively (paired with zramSwap on hosts).
        boot.kernel.sysctl."vm.swappiness" = 180;

        # Wi-Fi/Bluetooth firmware; also enables hardware.cpu.*.updateMicrocode
        # via the mkDefault in hardware-configuration.nix.
        hardware.enableRedistributableFirmware = true;
      }

      (lib.mkIf cfg.secureBoot {
        boot.lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
        };

        environment.systemPackages = [ pkgs.sbctl ];
      })
    ]
  );
}
