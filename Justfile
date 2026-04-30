help:
    just --list

kanata:
    just files/kanata/setup
    stow kanata

nvim:
    stow nvim

tmux:
    stow tmux

claude:
    stow claude

zed:
    stow --no-folding zed

hammerspoon:
    stow hammerspoon

all: kanata nvim tmux claude zed hammerspoon
