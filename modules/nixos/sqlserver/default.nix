#
# sqlserver.nix — Microsoft SQL Server Linux (dev)
#
# Throwaway Developer-edition container bound to localhost only.
# Does not start at boot — `sudo systemctl start docker-sqlserver` when needed.
# Credentials are default/dev values — not intended for anything exposed.
#
{
  config,
  lib,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.sqlserver;
in
{
  options.${namespace}.sqlserver.enable =
    lib.mkEnableOption "throwaway SQL Server 2022 dev container (manual start)";

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.sqlserver = {
      image = "mcr.microsoft.com/mssql/server:2022-latest";
      autoStart = false;

      ports = [ "127.0.0.1:1433:1433" ];

      environment = {
        ACCEPT_EULA = "Y";
        MSSQL_SA_PASSWORD = "SqlServer!Dev2022";
        MSSQL_PID = "Developer";
      };

      volumes = [ "sqlserver-data:/var/opt/mssql" ];
    };
  };
}
