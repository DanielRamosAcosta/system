{
  description = "Configuración de NixOS de Daniel Ramos";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  inputs.agenix.url = "github:ryantm/agenix";
  inputs.agenix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.stylix.url = "github:nix-community/stylix/release-25.11";
  inputs.stylix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager/release-25.11";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    self,
    nixpkgs,
    disko,
    agenix,
    stylix,
    home-manager,
    ...
  } @ inputs:
    let
      nasSystem = "x86_64-linux";
      nasPkgs = nixpkgs.legacyPackages.${nasSystem};
      forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-linux" "x86_64-linux" ];
    in {
      packages.${nasSystem} = {
        quadro-ctl = nasPkgs.callPackage ./packages/quadro-ctl.nix {};
      };

      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              nixos-rebuild
              agenix.packages.${system}.default
            ];

            shellHook = ''
              export EDITOR=nano
            '';
          };
        }
      );

      nixosConfigurations = {
        nas = nixpkgs.lib.nixosSystem {
          system = nasSystem;
          modules = [
            ./hosts/nas
            disko.nixosModules.disko
            agenix.nixosModules.default
            {
              nixpkgs.overlays = [
                (final: prev: {
                  quadro-ctl = nasPkgs.callPackage ./packages/quadro-ctl.nix {};
                })
              ];
            }
          ];
        };

        siemens = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/siemens
            stylix.nixosModules.stylix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.dani = import ./hosts/siemens/home.nix;
            }
          ];
        };

        iso = nixpkgs.lib.nixosSystem {
          system = nasSystem;
          modules = [
            ./hosts/iso
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ];
        };
      };
    };
}
