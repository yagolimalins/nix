#
# postgresql.nix — PostgreSQL dev database
#
# A throwaway Postgres 18 container bound to localhost only. Credentials
# are default/dev values — not intended for anything exposed.
#
{ config, pkgs, ... }:

{
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
