# ThinkPad T480: i915, TLP, thinkfan, thermald.
{ ... }:

{
  boot.initrd.availableKernelModules = [ "usbhid" ];
  boot.initrd.kernelModules = [ "i915" ];
  boot.kernelParams = [
    "i915.fastboot=1"
    "i915.enable_psr=2"
    "i915.enable_fbc=1"
    "mem_sleep_default=deep"
    "nvme_core.default_ps_max_latency_us=5500"
    "nmi_watchdog=0"
  ];

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_BAT = 60;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;
      SCHED_POWERSAVE_ON_AC = 0;
      SCHED_POWERSAVE_ON_BAT = 1;

      INTEL_GPU_MIN_FREQ_ON_AC = 300;
      INTEL_GPU_MAX_FREQ_ON_AC = 1100;
      INTEL_GPU_MIN_FREQ_ON_BAT = 300;
      INTEL_GPU_MAX_FREQ_ON_BAT = 500;

      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";
      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";

      # Denylist keeps flaky dongles awake. Keep powertop auto-tune off —
      # it ignores USB_DENYLIST and suspends everything.
      USB_AUTOSUSPEND = 1;
      USB_DENYLIST = "1532:006e 320f:5000 25a7:fa70 3554:f5d5";
      USB_EXCLUDE_BTUSB = 1;

      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";

      MAX_LOST_WORK_SECS_ON_AC = 15;
      MAX_LOST_WORK_SECS_ON_BAT = 60;

      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
      START_CHARGE_THRESH_BAT1 = 75;
      STOP_CHARGE_THRESH_BAT1 = 80;
    };
  };

  services.thermald.enable = true;
  services.fwupd.enable = true;

  services.thinkfan = {
    enable = true;
    levels = [
      [
        0
        0
        50
      ]
      [
        1
        45
        55
      ]
      [
        2
        50
        60
      ]
      [
        3
        55
        65
      ]
      [
        4
        60
        70
      ]
      [
        5
        65
        75
      ]
      [
        7
        70
        32767
      ]
    ];
  };

  systemd.services.tlp-usb = {
    description = "Apply TLP USB autosuspend settings";
    after = [
      "tlp.service"
      "graphical.target"
    ];
    wantedBy = [ "graphical.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/tlp usb";
    };
  };

  zramSwap.enable = true;
  powerManagement.powertop.enable = false;
  services.acpid.enable = true;
  services.earlyoom.enable = true;
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };
}
