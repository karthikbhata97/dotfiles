help:
    just --list

kanata:
    just files/kanata/setup
    stow kanata

nvim:
    stow nvim

tmux:
    stow tmux

all: kanata nvim tmux
