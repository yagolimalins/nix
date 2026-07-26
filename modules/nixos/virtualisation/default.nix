#
# virtualisation.nix — Containers, VMs and local AI
#
# Docker as the container runtime (also the OCI-containers backend used by
# postgresql.nix), libvirt/QEMU/KVM + virt-manager for VMs, plus a local
# Ollama service. Docker and Ollama are not started on boot — start on
# demand with `sudo systemctl start docker|ollama`.
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
    virtualisation.docker.enable = true;
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
