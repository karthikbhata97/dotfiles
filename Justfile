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

all: kanata nvim tmux claude
