help:
    just --list

kanata:
    just files/kanata/setup
    stow kanata

nvim:
    # --no-folding: symlink only ~/.config/nvim, never fold ~/.config into the
    # repo. Without it stow turns ~/.config itself into a symlink, so gh/jj/git
    # etc. write their state straight into this repo.
    stow --no-folding nvim

tmux:
    stow tmux

claude:
    stow --no-folding claude

zed:
    stow --no-folding zed

hammerspoon:
    stow hammerspoon

# Caps Lock tricks for machines WITHOUT kanata: layers the Caps->F18 nav layer
# on top of the base hammerspoon config and installs the hidutil LaunchAgent.
# When kanata is present, use the plain `hammerspoon` target instead so these
# tricks don't fight kanata's own Caps layer.
hammerspoon-nokanata: hammerspoon
    stow hammerspoon-nokanata
    just files/hammerspoon/setup

cursor:
    [ -f "$HOME/Library/Application Support/Cursor/User/keybindings.json" ] || printf '[]\n' > "$HOME/Library/Application Support/Cursor/User/keybindings.json"
    tmp_settings=$(mktemp) && jq -s '.[0] * .[1]' "$HOME/Library/Application Support/Cursor/User/settings.json" "{{justfile_directory()}}/cursor/settings.json" > "$tmp_settings" && mv "$tmp_settings" "$HOME/Library/Application Support/Cursor/User/settings.json"
    tmp_keys=$(mktemp) && jq -s '.[0] as $base | .[1] as $overlay | reduce $overlay[] as $item ($base; map(select(.key != $item.key or ((.when // "") != ($item.when // "")))) + [$item])' "$HOME/Library/Application Support/Cursor/User/keybindings.json" "{{justfile_directory()}}/cursor/keybindings.json" > "$tmp_keys" && mv "$tmp_keys" "$HOME/Library/Application Support/Cursor/User/keybindings.json"

all: kanata nvim tmux claude zed hammerspoon cursor

# NixOS VM: apply ./nixos host config (default: baremin) on the VM itself.
nixos host="baremin":
    sudo nixos-rebuild switch --flake "{{justfile_directory()}}/nixos#{{host}}"

nixos-build host="baremin":
    nixos-rebuild build --flake "{{justfile_directory()}}/nixos#{{host}}"

# Proxmox template image (vzdump .vma.zst) of a host, in ./result-<host>.
# Needs an x86_64 Linux box with Nix (the Proxmox node or any NixOS VM).
nixos-image host="baremin":
    nix --extra-experimental-features "nix-command flakes" build "{{justfile_directory()}}/nixos#nixosConfigurations.{{host}}.config.system.build.VMA" -o "result-{{host}}"
