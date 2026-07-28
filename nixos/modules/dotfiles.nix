{ config, lib, pkgs, ... }:

let
  cfg = config.dotfiles;
  home = config.users.users.${cfg.user}.home;
in
{
  options.dotfiles = {
    user = lib.mkOption {
      type = lib.types.str;
      default = "an0ne";
      description = "User whose home gets the dotfiles stowed into it.";
    };
    repo = lib.mkOption {
      type = lib.types.str;
      default = "https://github.com/karthikbhata97/dotfiles.git";
      description = "Cloned to ~/dotfiles when it does not exist yet.";
    };
    recipes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "nvim" "tmux" ];
      description = "Justfile recipes to run from ~/dotfiles.";
    };
  };

  # Runs on boot and on every `nixos-rebuild switch` that changes it. An
  # existing ~/dotfiles is never pulled or touched beyond re-running stow.
  config.systemd.services.dotfiles-bootstrap = {
    description = "Clone and stow dotfiles for ${cfg.user}";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    path = with pkgs; [ bash coreutils gnugrep git stow just rustup ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = cfg.user;
      WorkingDirectory = home;
    };
    script = ''
      if [ ! -e "$HOME/dotfiles" ]; then
        git clone ${lib.escapeShellArg cfg.repo} "$HOME/dotfiles"
      fi
      cd "$HOME/dotfiles"
      mkdir -p "$HOME/.config"
      just ${lib.escapeShellArgs cfg.recipes}

      if ! rustup toolchain list | grep -q stable; then
        rustup default stable
      fi
    '';
  };
}
