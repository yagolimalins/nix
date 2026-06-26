{ config, pkgs, ... }:

{
  virtualisation.oci-containers.backend = "docker";
  
  virtualisation.oci-containers.containers.postgres = {
    image     = "postgres:18";
    autoStart = true;

    ports = [ "127.0.0.1:5432:5432" ];

    environment = {
      POSTGRES_USER     = "postgres";
      POSTGRES_DB       = "postgres";
      POSTGRES_PASSWORD = "postgres";
    };

    volumes = [ "postgres-data:/var/lib/postgresql" ];
  };
}
