{
  description = "an0ne's NixOS VMs";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
    let
      # Every host gets the shared modules (packages, an0ne user, dotfiles
      # bootstrap) plus its own ./hosts/<name> directory, which also picks the
      # platform (e.g. modules/proxmox.nix).
      mkHost = name: nixpkgs.lib.nixosSystem {
        specialArgs.host = name;
        modules = [
          self.nixosModules.default
          ./hosts/${name}
          { networking.hostName = nixpkgs.lib.mkDefault name; }
        ];
      };
    in
    {
      nixosModules.default = ./modules;

      nixosConfigurations = nixpkgs.lib.genAttrs [
        "baremin"
        "pocketid"
        "actualbudget"
        # add specialised hosts here, each with its own ./hosts/<name>/default.nix
      ] mkHost;
    };
}
