# Proxmox VM built from this flake's image (`just nixos-image`), not from the
# ISO installer. Importing the image module into the running system too keeps
# the disk layout, bootloader and cloud-init identical between the template
# and later `nixos-rebuild switch`es on its clones.
{ host, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/proxmox-image.nix")
    (modulesPath + "/profiles/qemu-guest.nix") # virtio drivers in the initrd
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Defaults for the restored template; change per clone in Proxmox.
  # Image file is vzdump-qemu-9999-<host>.vma.zst: Proxmox only treats a
  # backup as a VM backup when a VMID follows "qemu-". 9999 matches the disk
  # names nixpkgs bakes in. The restored VM is named <host>.
  proxmox.filenameSuffix = lib.mkDefault "9999-${host}";
  proxmox.qemuConf = {
    name = lib.mkDefault host;
    bios = "ovmf"; # UEFI, so the shared systemd-boot config works
    cores = lib.mkDefault 2;
    memory = lib.mkDefault 4096;
  };

  # The image is built in a VM with no EFI variables; systemd-boot then
  # installs itself to the fallback EFI/BOOT path, which OVMF boots.
  boot.loader.efi.canTouchEfiVariables = false;

  # Proxmox's cloud-init (VM name -> hostname, IP config) drives
  # systemd-networkd; NetworkManager would fight it.
  networking.networkmanager.enable = false;

  # Return freed blocks to thin LVM / ZFS storage (needs Discard on the disk).
  services.fstrim.enable = lib.mkDefault true;

  # Kernel/login output on the image's serial port (xterm.js console) and the
  # default noVNC console; tty0 last keeps noVNC the primary one.
  boot.kernelParams = [ "console=ttyS0,115200" "console=tty0" ];
}
