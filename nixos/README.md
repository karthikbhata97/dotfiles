# NixOS VMs

Every host gets `modules/` (stow, just, jj, ripgrep, fd, fish, nvim, tmux,
tree-sitter, rustup + build deps, user `an0ne` in `wheel` with fish as login
shell) and a `dotfiles-bootstrap` service that clones this repo to
`~an0ne/dotfiles`, runs `just nvim tmux`, and sets `rustup default stable`.

Hosts are Proxmox VMs (`modules/proxmox.nix`): a host is built into a
template image once, and new VMs are clones of it. No ISO install.

## Build the template

GitHub Actions does it (`.github/workflows/nixos-image.yml`): every push to
master touching `nixos/` rebuilds `baremin`, and Actions → nixos-image →
"Run workflow" builds any host. The image lands on the `image-<host>` release.
(Locally on x86_64 Linux with Nix: `just nixos-image [host]`.)

On the Proxmox node (host shell, or "Shell" in the web UI):

```sh
cd /var/lib/vz/dump
wget -O vzdump-qemu-baremin.vma.zst \
  https://github.com/karthikbhata97/dotfiles/releases/download/image-baremin/vzdump-qemu-baremin.vma.zst
qmrestore vzdump-qemu-baremin.vma.zst 9999 --unique true --storage local-lvm
qm template 9999
```

(Or after the wget: web UI → local → Backups → Restore as VM 9999, then
right-click → Convert to template.) The image's disk and cloud-init drive are
named for VMID 9999, so restore to that. It's UEFI (OVMF), virtio disk,
serial console, QEMU agent on, 2 cores, 4 GiB. The release is public, like
this repo; the image holds nothing secret (only public SSH keys).

## New VM

Web UI: right-click template → Clone (Full Clone, name = hostname); Hardware
→ disk → Resize; Cloud-Init → IP Config: DHCP; Start. Or in the host shell:

```sh
qm clone 9999 <id> --name <hostname> --full
qm resize <id> virtio0 +30G     # image is minimal; root grows on boot
qm set <id> --ipconfig0 ip=dhcp # cloud-init network (or ip=…/24,gw=…)
qm start <id>
```

The VM name becomes the hostname (cloud-init). Then `ssh an0ne@<vm>` with
one of the keys in `keys/an0ne.pub` (a copy of github.com/karthikbhata97.keys;
refresh with `curl https://github.com/karthikbhata97.keys > nixos/keys/an0ne.pub`
and rebuild). an0ne has no password and SSH password login is off; sudo
needs none. `systemctl status dotfiles-bootstrap` shows the clone/stow log.

Later changes: edit, then `just nixos [host]` from `~/dotfiles` on the VM.

## Adding a host

Create `hosts/<name>/default.nix` (import `../baremin` to start from it, then
add packages/services), and add `"<name>"` to the list in `flake.nix`:

```nix
{ pkgs, ... }: {
  imports = [ ../baremin ];
  environment.systemPackages = [ pkgs.nodejs ]; # e.g. for copilot
  virtualisation.docker.enable = true;
  dotfiles.recipes = [ "nvim" "tmux" "claude" ];
}
```

Either build its own template with `just nixos-image <name>`, or clone the
baremin template and `just nixos <name>` on the clone.
