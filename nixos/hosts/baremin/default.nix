# The minimal VM: just the shared modules, as a Proxmox image/template.
{
  imports = [ ../../modules/proxmox.nix ];

  # Release the image was first built with; leave it when updating nixpkgs.
  system.stateVersion = "26.05";
}
