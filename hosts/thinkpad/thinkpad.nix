{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ "usbhid" ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.extraModprobeConfig = "options btusb enable_autosuspend=0";
  boot.kernelParams = [
    "i915.fastboot=1"
    "i915.enable_psr=1"
    "i915.enable_fbc=1"
    "mem_sleep_default=deep"
    "nvme_core.default_ps_max_latency_us=5500"
    "nmi_watchdog=0"
  ];

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC  = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC  = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0  = 80;
      START_CHARGE_THRESH_BAT1 = 75;
      STOP_CHARGE_THRESH_BAT1  = 80;
      WIFI_PWR_ON_BAT    = 5;
      RUNTIME_PM_ON_AC   = "on";
      RUNTIME_PM_ON_BAT  = "auto";
      USB_AUTOSUSPEND    = 1;
      USB_DENYLIST       = "1532:006e 320f:5000";
      USB_EXCLUDE_BTUSB  = 1;
      PCIE_ASPM_ON_BAT   = "powersupersave";
    };
  };

  services.thermald.enable = true;
  services.fwupd.enable    = true;

  services.thinkfan = {
    enable = true;
    levels = [
      [0  0  55]
      [1  48 60]
      [2  55 65]
      [3  60 70]
      [4  65 75]
      [5  70 80]
      [7  75 32767]
    ];
  };

  systemd.services.tlp-usb = {
    description = "Apply TLP USB autosuspend settings";
    after       = [ "tlp.service" "graphical.target" ];
    wantedBy    = [ "graphical.target" ];
    serviceConfig = {
      Type      = "oneshot";
      ExecStart = "/run/current-system/sw/bin/tlp usb";
    };
  };

  zramSwap.enable                  = true;
  powerManagement.powertop.enable  = true;
  services.acpid.enable            = true;
  services.earlyoom.enable         = true;
  services.fstrim = {
    enable   = true;
    interval = "weekly";
  };
}
