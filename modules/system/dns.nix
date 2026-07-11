#
# dns.nix — Resolver and network-wide ad blocking
#
# AdGuard Home listens on 127.0.0.1:5335 as the upstream (DoH to
# Cloudflare/Quad9); systemd-resolved points every lookup at it. Its web
# UI is on 127.0.0.1:9000.
#
{ ... }:

{
  services.adguardhome = {
    enable          = true;
    mutableSettings = true;
    host            = "127.0.0.1";
    port            = 9000;
    settings.dns = {
      bind_host     = "127.0.0.1";
      port          = 5335;
      bootstrap_dns = [ "1.1.1.1" "9.9.9.9" ];
      upstream_dns  = [
        "https://dns.cloudflare.com/dns-query"
        "https://dns10.quad9.net/dns-query"
      ];
    };
  };

  services.resolved = {
    enable                  = true;
    settings.Resolve.DNS    = "127.0.0.1:5335";
    settings.Resolve.DNSSEC = "false";
  };
}
