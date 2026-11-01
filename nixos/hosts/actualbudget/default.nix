# Actual Budget. HTTPS is terminated by `tailscale serve` (svc:actual) on the
# Proxmox node, which proxies to port 3000 here. Login is via Pocket ID.
{
  imports = [ ../baremin ];

  services.actual = {
    enable = true;
    openFirewall = true;
    settings = {
      loginMethod = "openid";
      enforceOpenId = true;
      openId = {
        # This VM isn't on the tailnet, so it can't reach
        # pocketid.quail-bicolor.ts.net: only the browser-facing authorize URL
        # uses it, and the token/userinfo calls go straight to the Pocket ID VM.
        # Without discovery Actual can't verify id_tokens, hence "oauth2": the
        # identity comes from the userinfo endpoint instead.
        authMethod = "oauth2";
        issuer = {
          name = "Pocket ID";
          authorization_endpoint = "https://pocketid.quail-bicolor.ts.net/authorize";
          token_endpoint = "http://10.77.0.101:1411/api/oidc/token";
          userinfo_endpoint = "http://10.77.0.101:1411/api/oidc/userinfo";
        };
        client_id = "f0113f4a-b891-4d82-b184-275b8ebfacbf";
        server_hostname = "https://actual.quail-bicolor.ts.net";
      };
    };
  };

  # The client secret is kept out of the repo (it's public); created once by
  # hand on the VM, like Pocket ID's encryption key.
  systemd.services.actual = {
    serviceConfig.LoadCredential = [
      "openid-client-secret:/var/lib/secrets/actual/openid-client-secret"
    ];
    environment.ACTUAL_OPENID_CLIENT_SECRET_FILE = "%d/openid-client-secret";
  };
}
