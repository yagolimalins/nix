# Laptop: amdgpu, TLP.
{ ... }:

{
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.tlp = {
    enable = true;
    settings = {
      # Ryzen 7 3700U has no CPPC, so amd-pstate never loads and boost stays
      # on acpi-cpufreq's default. Cap battery at the 2.3 GHz base (kHz) so
      # the 4.0 GHz turbo cannot run away from the powersave governor.
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_SCALING_MAX_FREQ_ON_BAT = 2300000;

      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";
      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";

      # Integrated camera, Bluetooth, and the Realtek USB ethernet dongle.
      USB_AUTOSUSPEND = 1;
      USB_DENYLIST = "174f:1176 0cf3:e500 0bda:8153";
      USB_EXCLUDE_BTUSB = 1;

      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";

      MAX_LOST_WORK_SECS_ON_AC = 15;
      MAX_LOST_WORK_SECS_ON_BAT = 60;

      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
    };
  };

  powerManagement.powertop.enable = false;
}
