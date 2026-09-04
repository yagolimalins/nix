#
# virtualisation.nix — Containers, VMs and local AI
#
# Docker as the container runtime (also the OCI-containers backend used by
# postgresql.nix and sqlserver.nix), libvirt/QEMU/KVM + virt-manager for VMs, plus a local
# Ollama service. Docker + Postgres both start at boot. Ollama: start with
# `sudo systemctl start ollama`.
#
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.virtualisation;
in
{
  options.${namespace}.virtualisation.enable =
    lib.mkEnableOption "Docker, libvirt/QEMU/KVM, virt-manager and local Ollama";

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      daemon.settings.live-restore = false;
    };
    virtualisation.oci-containers.backend = "docker";

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        swtpm.enable = true;
      };
    };
    virtualisation.spiceUSBRedirection.enable = true;

    programs.virt-manager.enable = true;

    services.ollama.enable = true;

    # Ollama does not autostart on boot — start manually when needed.
    systemd.services.ollama.wantedBy = lib.mkForce [ ];
  };
}
