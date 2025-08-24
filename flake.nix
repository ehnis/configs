{
  inputs = {
    home-manager = {
      url = "git+https://github.com/nix-community/home-manager?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "git+https://github.com/hyprwm/hyprland-plugins?shallow=1";
      inputs.hyprland.follows = "hyprland";
    };
    nur = {
      url = "git+https://github.com/nix-community/NUR?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "git+https://github.com/Gerg-L/spicetify-nix?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "git+https://github.com/nix-community/nix-index-database?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpak = {
      url = "git+https://github.com/nixpak/nixpak?shallow=1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "git+https://github.com/NixOS/nixpkgs?shallow=1&ref=nixos-unstable";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?shallow=1";
    #chaotic.url = "git+https://github.com/chaotic-cx/nyx/nyxpkgs-unstable";
    pipewire-screenaudio.url = "git+https://github.com/IceDBorn/pipewire-screenaudio?shallow=1";
    #determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    nix-alien.url = "git+https://github.com/thiagokokada/nix-alien?shallow=1";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    nix-search.url = "git+https://github.com/diamondburned/nix-search?shallow=1";
  };

  outputs =
    { nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      modules-list = [
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            extraSpecialArgs = {
              inherit inputs;
            };
            backupFileExtension = "backup";
            useGlobalPkgs = true;
            useUserPackages = true;
          };
        }
      ];
      user = "ehnis";
      user-hash = "$y$j9T$EdzvK4wCXlFTLQYN/LUFJ/$iAJ1pjZ3tT7Uq.mf59cgdyntO4sLhsVA7XDwfEYaPu/";
    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs user user-hash;
          };
          modules = modules-list ++ [
            ./machines/nixos/configuration.nix
            { home-manager.users."${user}" = import ./machines/nixos/home.nix; }
          ];
        };
      };
      homeConfigurations = {
        ehnis = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${system};
          modules = [
            ./machines/nixos/home-options.nix
          ];
          extraSpecialArgs = {
            inherit inputs system user;
          };
        };
      };
    };
}
