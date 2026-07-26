#
# boot.nix — Bootloader, kernel and low-level tuning
#
# EFI: Lanzaboote (Secure Boot) or systemd-boot. BIOS/VM without ESP: GRUB.
#
# Secure Boot enrollment (once per bare-metal EFI machine):
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
# Bail out: mine.boot.secureBoot = false;
# BIOS / no ESP: mine.boot.efi = false; (optional mine.boot.grubDevice)
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

    efi = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Use an EFI bootloader (systemd-boot or Lanzaboote). Set false for BIOS
        guests or machines without a mounted ESP at boot.loader.efi.efiSysMountPoint.
      '';
    };

    grubDevice = lib.mkOption {
      type = lib.types.str;
      default = "/dev/vda";
      description = "Disk for GRUB MBR install when efi = false (typical QEMU: /dev/vda).";
    };

    secureBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Use Lanzaboote for UEFI Secure Boot (signed UKIs). When false on EFI,
        falls back to unsigned systemd-boot. Ignored when efi = false.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        boot = {
          kernelPackages = pkgs.linuxPackages_latest;
          kernelParams = [
            "quiet"
            "loglevel=3"
          ];

          initrd.systemd.enable = true;

          tmp.useTmpfs = true;

          kernel.sysctl."vm.swappiness" = 180;
        };

        hardware.enableRedistributableFirmware = true;
      }

      (lib.mkIf cfg.efi {
        boot.loader = {
          efi.canTouchEfiVariables = true;
          systemd-boot = {
            enable = lib.mkForce (!(cfg.secureBoot));
            configurationLimit = 5;
          };
          grub.enable = lib.mkForce false;
        };
      })

      (lib.mkIf (cfg.efi && cfg.secureBoot) {
        boot.lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
        };

        environment.systemPackages = [ pkgs.sbctl ];
      })

      (lib.mkIf (!cfg.efi) {
        boot.loader = {
          efi.canTouchEfiVariables = false;
          systemd-boot.enable = lib.mkForce false;
          grub = {
            enable = true;
            device = cfg.grubDevice;
            configurationLimit = 5;
          };
        };
      })
    ]
  );
}
