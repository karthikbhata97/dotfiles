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
    stow claude

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
