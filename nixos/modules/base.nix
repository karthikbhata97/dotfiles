{ config, lib, pkgs, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];
  };
  nixpkgs.config.allowUnfree = true;

  # UEFI boot; platforms/hosts can override (e.g. GRUB for BIOS-only VMs).
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  networking.networkmanager.enable = lib.mkDefault true;
  services.openssh.enable = lib.mkDefault true;
  time.timeZone = lib.mkDefault "America/New_York";

  security.sudo.wheelNeedsPassword = lib.mkDefault false;

  programs.fish.enable = true;

  # System-wide defaults in /etc/gitconfig; a user's ~/.gitconfig still wins.
  programs.git = {
    enable = true;
    config = {
      user.name = lib.mkDefault "Karthik";
      user.email = lib.mkDefault "karthik.bhata7@gmail.com";
    };
  };

  # jj ignores git's identity and has no system-wide config file, so pass the
  # same identity through its env vars. Unlike /etc/gitconfig these take
  # precedence over ~/.config/jj/config.toml.
  environment.variables = {
    JJ_USER = config.programs.git.config.user.name;
    JJ_EMAIL = config.programs.git.config.user.email;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Mason downloads prebuilt LSP binaries (lua_ls, ...) that expect a normal
  # FHS dynamic linker; nix-ld provides one.
  programs.nix-ld.enable = true;

  environment.systemPackages = with pkgs; [
    # dotfiles plumbing (git comes from programs.git above)
    stow
    just

    # CLI tools
    jujutsu
    ripgrep
    fd
    tmux
    jq
    curl
    wget
    unzip

    # rust: `rustup default stable` is run once by the dotfiles bootstrap;
    # cargo-binstall is there for anything not in nixpkgs.
    rustup
    cargo-binstall

    # nvim plugin builds: treesitter parsers, telescope-fzf-native.
    # No nodejs: copilot (`:MyCopilot on`) needs it; add pkgs.nodejs in a host
    # that wants it.
    tree-sitter
    gcc
    gnumake
  ];
}
