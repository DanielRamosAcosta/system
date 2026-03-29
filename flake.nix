{
  description = "Configuración de NixOS de Daniel Ramos";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

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
      localPkgs = nixpkgs.legacyPackages.${localSystem};
      remotePkgs = nixpkgs.legacyPackages.${remoteSystem};
    in {
      packages.${remoteSystem} = {
        quadro-ctl = remotePkgs.callPackage ./packages/quadro-ctl.nix {};
      };

      devShells.${localSystem}.default = localPkgs.mkShell {
        packages = with localPkgs; [
          nixos-rebuild
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
            {
              nixpkgs.overlays = [
                (final: prev: {
                  quadro-ctl = remotePkgs.callPackage ./packages/quadro-ctl.nix {};
                })
              ];
            }
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
