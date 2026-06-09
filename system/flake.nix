{
  description = "System Configuration Flake";

  inputs = {
    # Pinning exactly to the commit from your current channels
    nixpkgs.url = "github:nixos/nixpkgs/ac62194c3917";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixos-unstable, ... }@inputs: {
    nixosConfigurations = {
      camalouu = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./etc/nixos/configuration.nix
        ];
      };
    };
  };
}
