#
# virtualisation.nix — Containers and local AI
#
# Docker as the container runtime (also the OCI-containers backend used by
# postgresql.nix) plus a local Ollama service.
#
{ ... }:

{
  virtualisation.docker.enable          = true;
  virtualisation.oci-containers.backend = "docker";

  services.ollama.enable = true;
}
