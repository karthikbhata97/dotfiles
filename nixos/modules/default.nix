# Shared by every host, independent of where it runs. Hosts pick their
# platform (e.g. ./proxmox.nix) themselves.
{
  imports = [
    ./base.nix
    ./user.nix
    ./dotfiles.nix
  ];
}
