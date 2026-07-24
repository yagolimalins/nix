#
# virtualisation.nix — Containers and local AI
#
# Docker as the container runtime (also the OCI-containers backend used by
# postgresql.nix) plus a local Ollama service. Both are installed but not
# started on boot — start on demand with `sudo systemctl start docker|ollama`.
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.virtualisation;
in
{
  options.${namespace}.virtualisation.enable = lib.mkEnableOption "Docker + local Ollama";

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = true;
    virtualisation.oci-containers.backend = "docker";

    services.ollama.enable = true;

    # Ollama does not autostart on boot — start manually when needed.
    systemd.services.ollama.wantedBy = lib.mkForce [ ];
  };
}
