{
  description = "Configuración de NixOS de Daniel Ramos";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  inputs.agenix.url = "github:ryantm/agenix";
  inputs.agenix.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    self,
    nixpkgs,
    disko,
    agenix,
    ...
  } @ inputs:
    let
      localSystem = "aarch64-linux";
      remoteSystem = "x86_64-linux";
    in {
      devShells.${localSystem}.default = nixpkgs.legacyPackages.${localSystem}.mkShell {
        packages = [
          nixpkgs.legacyPackages.${localSystem}.nixos-rebuild
          agenix.packages.${localSystem}.default
        ];

        shellHook = ''
          export EDITOR=nano
        '';
      };

      nixosConfigurations = {
        nas = nixpkgs.lib.nixosSystem {
          system = remoteSystem;
          modules = [
            ./hosts/nas
            disko.nixosModules.disko
            agenix.nixosModules.default
          ];
        };

        iso = nixpkgs.lib.nixosSystem {
          system = remoteSystem;
          modules = [
            ./hosts/iso
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ];
        };
      };
    };
}
