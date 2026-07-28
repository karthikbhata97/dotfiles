{ config, lib, pkgs, ... }:

{
  # No password: an0ne gets in over SSH with the keys below (a copy of
  # github.com/karthikbhata97.keys) and sudo is passwordless. Set one later
  # with `sudo passwd an0ne` if console login is ever needed.
  users.users.an0ne = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]
      ++ lib.optional config.networking.networkmanager.enable "networkmanager";
    shell = pkgs.fish;
    openssh.authorizedKeys.keyFiles = [ ../keys/an0ne.pub ];
  };

  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
  };
}
