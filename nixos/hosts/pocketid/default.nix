# Pocket ID (passkey OIDC provider). HTTPS is terminated by `tailscale serve`
# on the Proxmox node, which proxies to port 1411 here.
{
  imports = [ ../baremin ];

  services.pocket-id = {
    enable = true;
    settings = {
      # Passkeys are bound to this hostname: settle it before enrolling any.
      APP_URL = "https://pocketid.quail-bicolor.ts.net";
      TRUST_PROXY = true;
    };
    # Kept out of the repo (it's public); created once by hand on the VM.
    credentials.ENCRYPTION_KEY = "/var/lib/secrets/pocket-id/encryption-key";
  };

  networking.firewall.allowedTCPPorts = [ 1411 ];
}
