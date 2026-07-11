#
# boot.nix — Bootloader, kernel and low-level tuning
#
# systemd-boot, the kernel package/params, tmpfs /tmp, kernel sysctls and
# redistributable firmware (which also pulls in CPU microcode updates).
#
{ config, pkgs, ... }:

{
  boot = {
    loader.systemd-boot.enable             = true;
    loader.systemd-boot.configurationLimit = 5; # keep the last 5 generations in the menu
    loader.efi.canTouchEfiVariables        = true;

    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams   = [ "quiet" "loglevel=3" ];

    initrd.systemd.enable = true;

    tmp.useTmpfs = true; # /tmp in RAM: faster builds, auto-cleared on reboot
  };

  # Prefer zram over disk swap aggressively (paired with zramSwap on hosts).
  boot.kernel.sysctl."vm.swappiness" = 180;

  # Wi-Fi/Bluetooth firmware; also enables hardware.cpu.*.updateMicrocode
  # via the mkDefault in hardware-configuration.nix.
  hardware.enableRedistributableFirmware = true;
}
